"""Repository rules for rules_fable."""

load("//fable:versions.bzl", "DEFAULT_FABLE_COMPILER_VERSION", "FABLE_COMPILER_VERSIONS")

def _fable_toolchain_repository_impl(ctx):
    version = ctx.attr.fable_version
    if version not in FABLE_COMPILER_VERSIONS:
        fail("Unsupported Fable compiler version '{}'. Supported versions: {}".format(
            version,
            ", ".join(sorted(FABLE_COMPILER_VERSIONS.keys())),
        ))

    metadata = FABLE_COMPILER_VERSIONS[version]
    fable_tool = metadata["fable"]
    baseline_packages = metadata["baseline_packages"]

    ctx.file("BUILD.bazel", """package(default_visibility = ["//visibility:public"])

load("@rules_fable//fable:defs.bzl", "fable_toolchain")

fable_toolchain(
    name = "fable_toolchain_impl",
    fable_version = "{version}",
    fable_tool_nupkg = "{fable_tool_nupkg}",
    package_nupkgs = {package_nupkgs},
)

toolchain(
    name = "fable_toolchain",
    toolchain = ":fable_toolchain_impl",
    toolchain_type = "@rules_fable//fable:toolchain_type",
)
""".format(
        version = version,
        fable_tool_nupkg = fable_tool["label"],
        package_nupkgs = repr([package["label"] for package in baseline_packages]),
    ))

fable_toolchain_repository = repository_rule(
    implementation = _fable_toolchain_repository_impl,
    attrs = {
        "fable_version": attr.string(
            default = DEFAULT_FABLE_COMPILER_VERSION,
            doc = "Fable compiler version from FABLE_COMPILER_VERSIONS.",
        ),
    },
    doc = "Creates a repository containing a Fable compiler toolchain.",
)
