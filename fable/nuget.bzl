"""Predeclared NuGet packages used by rules_fable."""

load("@rules_dotnet//dotnet:defs.bzl", "nuget_repo")
load(":versions.bzl", "DEFAULT_FABLE_COMPILER_VERSION", "FABLE_COMPILER_VERSIONS")

def rules_fable_nuget_packages():
    """Declares locked NuGet packages used by the default Fable rules."""
    metadata = FABLE_COMPILER_VERSIONS[DEFAULT_FABLE_COMPILER_VERSION]
    packages = []
    for package in [metadata["fable"]] + metadata["baseline_packages"]:
        packages.append({
            "id": package["id"],
            "version": package["version"],
            "sha512": package["sha512"],
            "sources": ["https://api.nuget.org/v3/index.json"],
            "dependencies": _empty_dependencies(),
            "targeting_pack_overrides": [],
            "framework_list": [],
        })

    nuget_repo(
        name = "rules_fable_nuget_packages",
        packages = packages,
    )

def _empty_dependencies():
    return {
        "net11": [],
        "net20": [],
        "net30": [],
        "net35": [],
        "net40": [],
        "net403": [],
        "net45": [],
        "net451": [],
        "net452": [],
        "net46": [],
        "net461": [],
        "net462": [],
        "net47": [],
        "net471": [],
        "net472": [],
        "net48": [],
        "net5.0": [],
        "net6.0": [],
        "net7.0": [],
        "net8.0": [],
        "netcoreapp1.0": [],
        "netcoreapp1.1": [],
        "netcoreapp2.0": [],
        "netcoreapp2.1": [],
        "netcoreapp2.2": [],
        "netcoreapp3.0": [],
        "netcoreapp3.1": [],
        "netstandard": [],
        "netstandard1.0": [],
        "netstandard1.1": [],
        "netstandard1.2": [],
        "netstandard1.3": [],
        "netstandard1.4": [],
        "netstandard1.5": [],
        "netstandard1.6": [],
        "netstandard2.0": [],
        "netstandard2.1": [],
    }
