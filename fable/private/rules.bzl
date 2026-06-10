"""Rule implementations for Fable."""

load("@rules_dotnet//dotnet/private:providers.bzl", "DotnetAssemblyRuntimeInfo", "NuGetInfo")
load("@rules_dotnet//dotnet/private/transitions:tfm_transition.bzl", "tfm_transition")
load(":providers.bzl", "FableBinaryInfo", "FableLibraryInfo", "FableToolchainInfo")

_DOTNET_TOOLCHAIN = "@rules_dotnet//dotnet:toolchain_type"
_FABLE_TOOLCHAIN = "//fable:toolchain_type"

def _xml_escape(value):
    return value.replace("&", "&amp;").replace("\"", "&quot;").replace("<", "&lt;").replace(">", "&gt;")

def _project_xml(srcs, target_framework, package_references):
    lines = [
        '<Project Sdk="Microsoft.NET.Sdk">',
        "  <PropertyGroup>",
        "    <TargetFramework>{}</TargetFramework>".format(_xml_escape(target_framework)),
        "    <EnableDefaultItems>false</EnableDefaultItems>",
    ]
    if _has_package_reference(package_references, "FSharp.Core"):
        lines.append("    <DisableImplicitFSharpCoreReference>true</DisableImplicitFSharpCoreReference>")
    lines.extend([
        "  </PropertyGroup>",
        "  <ItemGroup>",
    ])
    for src in srcs:
        lines.append('    <Compile Include="{}" />'.format(_xml_escape(src.short_path)))
    lines.append("  </ItemGroup>")
    if package_references:
        lines.append("  <ItemGroup>")
        for package, version in sorted(package_references.items()):
            lines.append(
                '    <PackageReference Include="{}" Version="{}" />'.format(
                    _xml_escape(package),
                    _xml_escape(version),
                ),
            )
        lines.append("  </ItemGroup>")
    lines.append("</Project>")
    return "\n".join(lines) + "\n"

def _has_package_reference(package_references, name):
    wanted = name.lower()
    for package in package_references.keys():
        if package.lower() == wanted:
            return True
    return False

def _merge_package_references(package_references, dep_package_references):
    merged = dict(package_references)
    for package, version in dep_package_references.items():
        if package in merged and merged[package] != version:
            fail("Conflicting versions for NuGet package {}: {} and {}".format(
                package,
                merged[package],
                version,
            ))
        merged[package] = version
    return merged

def _collect_nuget_dep(dep):
    packages = []
    if DotnetAssemblyRuntimeInfo in dep:
        runtime = dep[DotnetAssemblyRuntimeInfo]
        if runtime.nuget_info != None:
            packages.append(struct(
                name = runtime.name,
                version = runtime.version,
                nupkg = runtime.nuget_info.nupkg,
            ))
        for transitive_runtime in runtime.deps.to_list():
            if transitive_runtime.nuget_info != None:
                packages.append(struct(
                    name = transitive_runtime.name,
                    version = transitive_runtime.version,
                    nupkg = transitive_runtime.nuget_info.nupkg,
                ))
    elif NuGetInfo in dep:
        packages.append(struct(
            name = None,
            version = None,
            nupkg = dep[NuGetInfo].nupkg,
        ))
    return packages

def _collect_dep_metadata(deps, package_references):
    package_nupkgs = []
    transitive = []
    for dep in deps:
        if FableLibraryInfo in dep:
            info = dep[FableLibraryInfo]
            transitive.append(info.transitive_srcs)
            package_references = _merge_package_references(package_references, info.package_references)
            package_nupkgs.append(info.package_nupkgs)
            continue

        packages = _collect_nuget_dep(dep)
        if not packages:
            fail("deps must be fable_library/fable_binary targets or rules_dotnet NuGet package targets; got {}".format(dep.label))
        for package in packages:
            if package.name != None and package.version != None:
                package_references = _merge_package_references(package_references, {package.name: package.version})
            package_nupkgs.append(depset([package.nupkg]))

    return struct(
        package_references = package_references,
        package_nupkgs = depset(transitive = package_nupkgs),
        transitive_srcs = transitive,
    )

def _collect_deps(ctx):
    return _collect_dep_metadata(ctx.attr.deps, dict(ctx.attr.package_references))

def _fable_target_impl(ctx, is_binary):
    if is_binary:
        if not ctx.files.srcs:
            fail("fable_binary requires at least one source file.")
        entry_point = ctx.files.srcs[-1]
        if not entry_point.basename.endswith(".fs"):
            fail("fable_binary entrypoint must be the last direct .fs source file; got {}".format(entry_point.basename))
    else:
        entry_point = None

    deps = _collect_deps(ctx)
    transitive_srcs = depset(ctx.files.srcs, transitive = deps.transitive_srcs, order = "postorder")
    package_references = deps.package_references
    project_file = ctx.actions.declare_file(ctx.label.name + ".fsproj")
    ctx.actions.write(
        output = project_file,
        content = _project_xml(transitive_srcs.to_list(), ctx.attr.target_framework, package_references),
    )

    providers = [
        DefaultInfo(files = depset([project_file])),
        FableLibraryInfo(
            direct_srcs = ctx.files.srcs,
            transitive_srcs = transitive_srcs,
            target_framework = ctx.attr.target_framework,
            package_references = package_references,
            package_nupkgs = deps.package_nupkgs,
            project_file = project_file,
        ),
    ]
    if is_binary:
        providers.append(FableBinaryInfo(entry_point = entry_point))
    return providers

def _fable_library_impl(ctx):
    return _fable_target_impl(ctx, is_binary = False)

def _fable_binary_impl(ctx):
    return _fable_target_impl(ctx, is_binary = True)

def _fable_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            fableinfo = FableToolchainInfo(
                fable_version = ctx.attr.fable_version,
                fable_tool_nupkg = ctx.file.fable_tool_nupkg,
                package_nupkgs = depset(ctx.files.package_nupkgs),
            ),
        ),
    ]

_FABLE_TARGET_ATTRS = {
    "srcs": attr.label_list(
        allow_files = [".fs", ".fsi"],
        doc = "Ordered F# source files. F# compilation order is significant.",
        mandatory = True,
    ),
    "deps": attr.label_list(
        cfg = tfm_transition,
        doc = "Other fable_library/fable_binary targets or rules_dotnet NuGet package targets.",
    ),
    "target_framework": attr.string(
        default = "netstandard2.1",
        doc = "Target framework moniker for the generated fsproj.",
    ),
    "package_references": attr.string_dict(
        default = {},
        doc = "NuGet PackageReference entries to include in generated fsproj files.",
    ),
    "_allowlist_function_transition": attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    ),
}

_fable_library_rule = rule(
    implementation = _fable_library_impl,
    attrs = _FABLE_TARGET_ATTRS,
    doc = "Collects ordered F# sources and generates an fsproj for Fable.",
)

fable_binary = rule(
    implementation = _fable_binary_impl,
    attrs = _FABLE_TARGET_ATTRS,
    doc = "Collects ordered F# binary sources and treats the final direct .fs file as the entrypoint.",
)

fable_toolchain = rule(
    implementation = _fable_toolchain_impl,
    attrs = {
        "fable_version": attr.string(
            mandatory = True,
            doc = "Fable compiler version.",
        ),
        "fable_tool_nupkg": attr.label(
            allow_single_file = [".nupkg"],
            mandatory = True,
            doc = "Fable .NET tool NuGet package.",
        ),
        "package_nupkgs": attr.label_list(
            allow_files = [".nupkg"],
            doc = "Baseline NuGet package artifacts available to generated Fable projects.",
        ),
    },
    doc = "Defines a Fable compiler toolchain implementation.",
)

def fable_library(name, **kwargs):
    """Collects ordered F# sources and generates an fsproj for Fable.

    Also creates a `<name>_lib` alias for BUILD files that use a library-style
    naming convention at consumption sites.
    """
    _fable_library_rule(
        name = name,
        **kwargs
    )
    native.alias(
        name = name + "_lib",
        actual = ":" + name,
    )

def _copy_inputs_fragment(srcs):
    lines = []
    for index, src in enumerate(srcs):
        lines.append('cp "$PWD/{src}" "$project_dir/{target}"'.format(
            src = src.path,
            target = _indexed_basename(index, src.basename),
        ))
    return "\n".join(lines)

def _copy_feed_fragment(nupkgs):
    lines = []
    for nupkg in nupkgs:
        lines.append('cp "$execroot/{src}" "$feed_dir/{basename}"'.format(
            src = nupkg.path,
            basename = nupkg.basename,
        ))
    return "\n".join(lines)

def _indexed_basename(index, basename):
    padded = "0000" + str(index)
    return "src_" + padded[len(padded) - 4:] + "_" + basename.lower()

def _source_output_basename(index, basename, extension):
    indexed = _indexed_basename(index, basename)
    if indexed.endswith(".fs"):
        return indexed[:-3] + extension
    if indexed.endswith(".fsi"):
        return None
    fail("Expected an .fs or .fsi source, got {}".format(basename))

def _compile_items_fragment(srcs):
    lines = []
    for index, src in enumerate(srcs):
        lines.append('    <Compile Include="{target}" />'.format(
            target = _xml_escape(_indexed_basename(index, src.basename)),
        ))
    return "\n".join(lines)

def _package_references_fragment(package_references):
    lines = []
    for package, version in sorted(package_references.items()):
        lines.append('    <PackageReference Include="{}" Version="{}" />'.format(
            _xml_escape(package),
            _xml_escape(version),
        ))
    return "\n".join(lines)

def _implicit_fsharp_core_fragment(package_references):
    if _has_package_reference(package_references, "FSharp.Core"):
        return "    <DisableImplicitFSharpCoreReference>true</DisableImplicitFSharpCoreReference>"
    return ""

def _tool_manifest(version):
    return """{
  "version": 1,
  "isRoot": true,
  "tools": {
    "fable": {
      "version": "%s",
      "commands": [
        "fable"
      ]
    }
  }
}
""" % version

def _nuget_config():
    return """<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <clear />
    <add key="bazel" value="../feed" />
  </packageSources>
</configuration>
"""

def _shell_quote(value):
    return "'" + value.replace("'", "'\\''") + "'"

_PYTHON_IDENTIFIER_CHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

def _python_identifier(value):
    result = ""
    for index in range(len(value)):
        char = value[index]
        if char in _PYTHON_IDENTIFIER_CHARS:
            result += char
        else:
            result += "_"
    if not result:
        return "_"
    if result[0] in "0123456789":
        return "_" + result
    return result

def _python_launcher_content(package_name, module_name):
    return """import importlib
import sys
import types
from pathlib import Path

package_dir = Path(__file__).resolve().parent
package = types.ModuleType("{package_name}")
package.__path__ = [str(package_dir)]
sys.modules["{package_name}"] = package

module = importlib.import_module("{package_name}.{module_name}")

if hasattr(module, "main"):
    raise SystemExit(module.main(sys.argv[1:]))
""".format(
        package_name = package_name,
        module_name = module_name,
    )

def _outputs(ctx, srcs, extension, package_json):
    files = []
    by_source_path = {}
    for index, src in enumerate(srcs):
        output_basename = _source_output_basename(index, src.basename, extension)
        if output_basename == None:
            continue
        output = ctx.actions.declare_file(ctx.label.name + "/" + output_basename)
        files.append(output)
        by_source_path[src.path] = output
    fable_modules = ctx.actions.declare_directory(ctx.label.name + "/fable_modules")
    package_json_file = ctx.actions.declare_file(ctx.label.name + "/package.json") if package_json else None
    return struct(
        files = files,
        by_source_path = by_source_path,
        fable_modules = fable_modules,
        package_json = package_json_file,
    )

def _language_args(language):
    if language == "javascript":
        return ""
    return "--lang {}".format(_shell_quote(language))

def _package_json_fragment(out_dir, package_json):
    if package_json == None:
        return ""
    return """cat > "$execroot/{out_dir}/package.json" <<'__FABLE_OUTPUT_PACKAGE_JSON__'
{{"type":"module"}}
__FABLE_OUTPUT_PACKAGE_JSON__
""".format(out_dir = out_dir)

def _compile_fable(ctx, target, entry_point, language, extension, package_json):
    library = target[FableLibraryInfo]
    srcs = library.transitive_srcs.to_list()
    deps = _collect_dep_metadata(ctx.attr.deps, dict(library.package_references))
    outputs = _outputs(ctx, srcs, extension, package_json)
    entry_point_file = None
    if entry_point:
        if entry_point.path not in outputs.by_source_path:
            fail("Entrypoint {} was not present in the transitive source set.".format(entry_point.short_path))
        entry_point_file = outputs.by_source_path[entry_point.path]
    launcher = None
    if language == "python" and entry_point_file != None:
        launcher = ctx.actions.declare_file(ctx.label.name + "/" + ctx.label.name + ".py")
        module_name = entry_point_file.basename[:-3]
        ctx.actions.write(
            output = launcher,
            content = _python_launcher_content(
                "_fable_" + _python_identifier(ctx.label.name),
                module_name,
            ),
        )
    fable_toolchain = ctx.toolchains[_FABLE_TOOLCHAIN].fableinfo
    nupkgs = [fable_toolchain.fable_tool_nupkg] + fable_toolchain.package_nupkgs.to_list() + ctx.files.package_nupkgs + library.package_nupkgs.to_list() + deps.package_nupkgs.to_list()
    out_dir = outputs.files[0].dirname if outputs.package_json == None else outputs.package_json.dirname
    dotnet = ctx.toolchains[_DOTNET_TOOLCHAIN].dotnetinfo

    command = """set -euo pipefail
execroot="$PWD"
work_dir="${{TMPDIR:-/tmp}}/{workspace}_{name}"
rm -rf "$work_dir"
mkdir -p "$work_dir/project/.config" "$work_dir/feed" "$work_dir/dotnet_home" "$work_dir/nuget"
rm -rf "{out_dir}"
mkdir -p "{out_dir}"
export DOTNET_CLI_HOME="$work_dir/dotnet_home"
export DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1
export DOTNET_NOLOGO=1
export NUGET_PACKAGES="$work_dir/nuget"
project_dir="$work_dir/project"
feed_dir="$work_dir/feed"
{copy_feed}
cat > "$project_dir/NuGet.config" <<'__FABLE_NUGET_CONFIG__'
{nuget_config}
__FABLE_NUGET_CONFIG__
cat > "$project_dir/.config/dotnet-tools.json" <<'__FABLE_TOOL_MANIFEST__'
{tool_manifest}
__FABLE_TOOL_MANIFEST__
{copy_inputs}
cat > "$project_dir/{project_name}.fsproj" <<'__FABLE_PROJECT__'
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>{target_framework}</TargetFramework>
    <EnableDefaultItems>false</EnableDefaultItems>
{implicit_fsharp_core}
  </PropertyGroup>
  <ItemGroup>
{compile_items}
  </ItemGroup>
  <ItemGroup>
{package_references}
  </ItemGroup>
</Project>
__FABLE_PROJECT__
cd "$project_dir"
"$execroot/{dotnet}" tool restore
"$execroot/{dotnet}" tool run fable -- "{project_name}.fsproj" --outDir "$execroot/{out_dir}" {language_args} {fable_args}
{post_compile}
""".format(
        out_dir = out_dir,
        workspace = ctx.workspace_name,
        name = ctx.label.name,
        copy_feed = _copy_feed_fragment(nupkgs),
        nuget_config = _nuget_config(),
        tool_manifest = _tool_manifest(fable_toolchain.fable_version),
        copy_inputs = _copy_inputs_fragment(srcs),
        project_name = ctx.label.name,
        target_framework = _xml_escape(library.target_framework),
        implicit_fsharp_core = _implicit_fsharp_core_fragment(deps.package_references),
        compile_items = _compile_items_fragment(srcs),
        package_references = _package_references_fragment(deps.package_references),
        dotnet = dotnet.runtime_path,
        language_args = _language_args(language),
        fable_args = " ".join([_shell_quote(arg) for arg in ctx.attr.fable_args]),
        post_compile = _package_json_fragment(out_dir, outputs.package_json),
    )

    inputs = depset(srcs + nupkgs, transitive = [depset(dotnet.runtime_files)])
    action_outputs = outputs.files + [outputs.fable_modules]
    if outputs.package_json != None:
        action_outputs.append(outputs.package_json)
    runfiles = list(action_outputs)
    if launcher != None:
        runfiles.append(launcher)
    ctx.actions.run_shell(
        inputs = inputs,
        outputs = action_outputs,
        command = command,
        mnemonic = "FableTranspile",
        progress_message = "Transpiling F# with Fable %{label}",
    )

    if launcher != None:
        default_files = [launcher]
    elif entry_point_file:
        default_files = [entry_point_file]
    else:
        default_files = action_outputs
    return [
        DefaultInfo(
            files = depset(default_files),
            runfiles = ctx.runfiles(files = runfiles),
        ),
    ]

def _fable_js_library_impl(ctx):
    return _compile_fable(ctx, ctx.attr.library, None, "javascript", ".js", True)

def _fable_py_library_impl(ctx):
    return _compile_fable(ctx, ctx.attr.library, None, "python", ".py", False)

def _fable_js_binary_impl(ctx):
    binary = ctx.attr.binary
    return _compile_fable(ctx, binary, binary[FableBinaryInfo].entry_point, "javascript", ".js", True)

def _fable_py_binary_impl(ctx):
    binary = ctx.attr.binary
    return _compile_fable(ctx, binary, binary[FableBinaryInfo].entry_point, "python", ".py", False)

_FABLE_TRANSPILE_ATTRS = {
    "package_nupkgs": attr.label_list(
        allow_files = [".nupkg"],
        doc = "Extra package nupkgs used as the local NuGet source for project restore.",
    ),
    "fable_args": attr.string_list(
        doc = "Additional command-line arguments passed after the generated fsproj.",
    ),
    "deps": attr.label_list(
        cfg = tfm_transition,
        doc = "Additional fable_library/fable_binary targets or rules_dotnet NuGet package targets to include only for this transpilation target.",
    ),
    "target_framework": attr.string(
        default = "netstandard2.1",
        doc = "Target framework moniker used to resolve projection-level NuGet deps.",
    ),
    "_allowlist_function_transition": attr.label(
        default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
    ),
}

fable_js_library = rule(
    implementation = _fable_js_library_impl,
    attrs = dict(
        _FABLE_TRANSPILE_ATTRS,
        library = attr.label(
            mandatory = True,
            providers = [FableLibraryInfo],
            doc = "fable_library target to transpile.",
        ),
    ),
    doc = "Transpiles a fable_library to a JavaScript output directory.",
    toolchains = [_DOTNET_TOOLCHAIN, _FABLE_TOOLCHAIN],
)

fable_py_library = rule(
    implementation = _fable_py_library_impl,
    attrs = dict(
        _FABLE_TRANSPILE_ATTRS,
        library = attr.label(
            mandatory = True,
            providers = [FableLibraryInfo],
            doc = "fable_library target to transpile.",
        ),
    ),
    doc = "Transpiles a fable_library to a Python output directory.",
    toolchains = [_DOTNET_TOOLCHAIN, _FABLE_TOOLCHAIN],
)

fable_js_binary = rule(
    implementation = _fable_js_binary_impl,
    attrs = dict(
        _FABLE_TRANSPILE_ATTRS,
        binary = attr.label(
            mandatory = True,
            providers = [FableLibraryInfo, FableBinaryInfo],
            doc = "fable_binary target to transpile.",
        ),
    ),
    doc = "Transpiles a fable_binary to JavaScript and exposes its entrypoint for rules_js.",
    toolchains = [_DOTNET_TOOLCHAIN, _FABLE_TOOLCHAIN],
)

fable_py_binary = rule(
    implementation = _fable_py_binary_impl,
    attrs = dict(
        _FABLE_TRANSPILE_ATTRS,
        binary = attr.label(
            mandatory = True,
            providers = [FableLibraryInfo, FableBinaryInfo],
            doc = "fable_binary target to transpile.",
        ),
    ),
    doc = "Transpiles a fable_binary to Python and exposes its entrypoint as the default output.",
    toolchains = [_DOTNET_TOOLCHAIN, _FABLE_TOOLCHAIN],
)
