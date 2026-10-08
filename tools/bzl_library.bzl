"""Gazelle-compatible bzl_library wrapper with Stardoc extraction."""

load("@bazel_skylib//:bzl_library.bzl", _bzl_library = "bzl_library")

def bzl_library(name, srcs, deps = [], doc_deps = [], **kwargs):
    """Creates a bzl_library and a paired starlark_doc_extract target."""
    _bzl_library(
        name = name,
        srcs = srcs,
        deps = deps + doc_deps,
        **kwargs
    )

    if len(srcs) != 1:
        fail("bzl_library wrapper expects exactly one src for %s" % name)

    native.starlark_doc_extract(
        name = name + ".doc",
        src = srcs[0],
        deps = deps + doc_deps,
        tags = ["manual"],
    )
