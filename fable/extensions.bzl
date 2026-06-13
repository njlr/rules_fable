"""Bzlmod extensions for rules_fable."""

load(":nuget.bzl", "rules_fable_nuget_packages")
load(":repositories.bzl", "fable_toolchain_repository")
load(":versions.bzl", "DEFAULT_FABLE_COMPILER_VERSION")

def _nuget_extension_impl(_ctx):
    rules_fable_nuget_packages()

nuget = module_extension(
    implementation = _nuget_extension_impl,
)

def _toolchains_extension_impl(module_ctx):
    fable_version = DEFAULT_FABLE_COMPILER_VERSION
    root_version = None
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if mod.is_root:
                root_version = toolchain.fable_version
            elif root_version == None:
                fable_version = toolchain.fable_version
    if root_version != None:
        fable_version = root_version
    rules_fable_nuget_packages(fable_version = fable_version)
    fable_toolchain_repository(
        name = "fable_toolchains",
        fable_version = fable_version,
    )

toolchains = module_extension(
    implementation = _toolchains_extension_impl,
    tag_classes = {
        "toolchain": tag_class(
            attrs = {
                "fable_version": attr.string(default = DEFAULT_FABLE_COMPILER_VERSION),
            },
        ),
    },
)
