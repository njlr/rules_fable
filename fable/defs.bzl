"""Public API for rules_fable."""

load(
    "//fable/private:rules.bzl",
    _fable_binary = "fable_binary",
    _fable_js_binary = "fable_js_binary",
    _fable_js_library = "fable_js_library",
    _fable_library = "fable_library",
    _fable_py_binary = "fable_py_binary",
    _fable_py_library = "fable_py_library",
)

fable_binary = _fable_binary
fable_library = _fable_library
fable_js_binary = _fable_js_binary
fable_js_library = _fable_js_library
fable_py_binary = _fable_py_binary
fable_py_library = _fable_py_library
