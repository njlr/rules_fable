"""Known Fable compiler versions and locked package metadata."""

FABLE_COMPILER_VERSIONS = {
    "4.29.0": {
        "fable": {
            "id": "Fable",
            "version": "4.29.0",
            "sha512": "sha512-XJwzk2d24dLQdlf8LDQ16s9bpUGQwiTllDqE5/5jPMX1AVAPA2fwMJ8f2vgjlizidM2hGQvP75TM21Ln0q2lgg==",
            "label": "@nuget.fable.v4.29.0//:fable.4.29.0.nupkg",
        },
        "baseline_packages": [
            {
                "id": "Fable.Core",
                "version": "4.4.0",
                "sha512": "sha512-EyhF8YI/3+3Z0ttDiVmshbTM14E+TsT3xARstibvK8Mm97tfBLfeqC1vQpUZkRr8ibax3qcP/tNqUhjHZqY6qQ==",
                "label": "@nuget.fable.core.v4.4.0//:fable.core.4.4.0.nupkg",
            },
        ],
    },
    "5.1.0": {
        "fable": {
            "id": "Fable",
            "version": "5.1.0",
            "sha512": "sha512-0nuojNQJ74gGpfBOAzLAh1DQyFClV4pi4WPSDtk67iCU2pxM7Nl8k1JfV6hgvWZAFAI+ncnGCALd1wMdldgZlA==",
            "label": "@nuget.fable.v5.1.0//:fable.5.1.0.nupkg",
        },
        "baseline_packages": [
            {
                "id": "Fable.Core",
                "version": "5.0.0",
                "sha512": "sha512-65IxKwus/l/ceVMKsB3z41Szb4+1Zj63muviXFEK/u0ixYQjQ/emnFQdwVba6TL4oXhX/8NuHdoEVO+6dBX1gA==",
                "label": "@nuget.fable.core.v5.0.0//:fable.core.5.0.0.nupkg",
            },
        ],
    },
}

DEFAULT_FABLE_COMPILER_VERSION = "4.29.0"
