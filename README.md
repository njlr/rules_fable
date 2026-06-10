# Bazel rules for Fable

## Installation

With bzlmod:

```starlark
bazel_dep(name = "rules_fable", version = "0.0.0")

fable_toolchains = use_extension("@rules_fable//fable:extensions.bzl", "toolchains")
fable_toolchains.toolchain(fable_version = "4.29.0")
use_repo(fable_toolchains, "fable_toolchains")
register_toolchains("@fable_toolchains//:fable_toolchain")
```

## Usage

```starlark
load("@rules_fable//fable:defs.bzl", "fable_binary", "fable_js_binary", "fable_library", "fable_py_binary")

fable_library(
    name = "domain",
    srcs = [
        "Domain.fs",
    ],
)

fable_binary(
    name = "app",
    srcs = [
        "App.fs",
    ],
    deps = [":domain"],
)

fable_js_binary(
    name = "app_js",
    binary = ":app",
)

fable_py_binary(
    name = "app_py",
    binary = ":app",
)
```

`fable_library` and `fable_binary` keep the input simple: pass an ordered list
of `.fs` or `.fsi` files and they generate an `.fsproj` automatically. Generated
Fable projects target `netstandard2.1` by default. For `fable_binary`, the final
direct `.fs` file is the entrypoint, matching F# source ordering convention.

`deps` accepts other `fable_library`/`fable_binary` targets and rules_dotnet
NuGet package targets. NuGet deps contribute `PackageReference` entries and
their `.nupkg` files to the generated project automatically, including
transitive package deps.

`fable_js_library`, `fable_py_library`, `fable_js_binary`, and `fable_py_binary` use the
`rules_dotnet` .NET SDK toolchain to restore and run the Fable .NET local tool.
`fable_js_binary` exposes the generated entrypoint as its single default file
and includes the rest of the generated output in runfiles, so it can be passed
directly to `rules_js` targets such as
`js_binary(entry_point = ":app_js", data = [":app_js"])`.

The Fable compiler is selected through a Bazel toolchain. Known compiler
versions and their locked NuGet SHA512 metadata live in
`@rules_fable//fable:versions.bzl`; the `toolchains` extension creates a
toolchain repository for the selected version. The transpilation action builds
a local NuGet feed from declared `.nupkg` files and restores from that feed,
rather than resolving package versions during the action.

The default toolchain is .NET SDK `8.0.100`, with Fable `4.29.0`, generated
Fable projects targeting `netstandard2.1`, and baseline `Fable.Core` feed
package `4.4.0`. Projects can select package versions by depending on
rules_dotnet NuGet package targets.
