# Bazel rules for Fable

`rules_fable` integrates the [Fable compiler](https://github.com/fable-compiler/fable) with Bazel.

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
