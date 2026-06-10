"""Bzlmod extensions for rules_fable."""

load(":nuget.bzl", "rules_fable_nuget_packages")

def _nuget_extension_impl(_ctx):
    rules_fable_nuget_packages()

nuget = module_extension(
    implementation = _nuget_extension_impl,
)
