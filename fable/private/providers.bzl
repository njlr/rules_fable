"""Providers used by rules_fable."""

FableLibraryInfo = provider(
    doc = "Information needed to compile an F# library with Fable.",
    fields = {
        "direct_srcs": "Ordered direct F# source files for this library.",
        "transitive_srcs": "Ordered transitive F# source files, dependencies first.",
        "target_framework": "Target framework moniker used in the generated project.",
        "package_references": "NuGet package references for the generated project.",
        "package_nupkgs": "NuGet package files needed for the generated project restore.",
        "project_file": "Generated fsproj artifact for inspection and editor integration.",
    },
)

FableBinaryInfo = provider(
    doc = "Information needed to compile an F# binary with Fable.",
    fields = {
        "entry_point": "The final direct .fs source file, following F# source order convention.",
    },
)

FableToolchainInfo = provider(
    doc = "Information needed to run the Fable compiler.",
    fields = {
        "fable_version": "Fable compiler version.",
        "fable_tool_nupkg": "Fable .NET tool NuGet package artifact.",
        "package_nupkgs": "Baseline NuGet package artifacts always available to generated Fable projects.",
    },
)
