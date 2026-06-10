"""Predeclared NuGet packages used by rules_fable."""

load("@rules_dotnet//dotnet:defs.bzl", "nuget_repo")

def rules_fable_nuget_packages():
    """Declares locked NuGet packages used by the default Fable rules."""
    nuget_repo(
        name = "rules_fable_nuget_packages",
        packages = [
            {
                "id": "Fable",
                "version": "4.29.0",
                "sha512": "sha512-XJwzk2d24dLQdlf8LDQ16s9bpUGQwiTllDqE5/5jPMX1AVAPA2fwMJ8f2vgjlizidM2hGQvP75TM21Ln0q2lgg==",
                "sources": ["https://api.nuget.org/v3/index.json"],
                "dependencies": _empty_dependencies(),
                "targeting_pack_overrides": [],
                "framework_list": [],
            },
            {
                "id": "Fable.Core",
                "version": "4.4.0",
                "sha512": "sha512-EyhF8YI/3+3Z0ttDiVmshbTM14E+TsT3xARstibvK8Mm97tfBLfeqC1vQpUZkRr8ibax3qcP/tNqUhjHZqY6qQ==",
                "sources": ["https://api.nuget.org/v3/index.json"],
                "dependencies": _empty_dependencies(),
                "targeting_pack_overrides": [],
                "framework_list": [],
            },
        ],
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
