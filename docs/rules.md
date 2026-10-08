<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API for rules_fable.

<a id="fable_binary"></a>

## fable_binary

<pre>
load("@rules_fable//fable:defs.bzl", "fable_binary")

fable_binary(<a href="#fable_binary-name">name</a>, <a href="#fable_binary-deps">deps</a>, <a href="#fable_binary-srcs">srcs</a>, <a href="#fable_binary-package_references">package_references</a>, <a href="#fable_binary-target_framework">target_framework</a>)
</pre>

Collects ordered F# binary sources and treats the final direct .fs file as the entrypoint.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fable_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fable_binary-deps"></a>deps |  Other fable_library/fable_binary targets or rules_dotnet NuGet package targets.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_binary-srcs"></a>srcs |  Ordered F# source files. F# compilation order is significant.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="fable_binary-package_references"></a>package_references |  NuGet PackageReference entries to include in generated fsproj files.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="fable_binary-target_framework"></a>target_framework |  Target framework moniker for the generated fsproj.   | String | optional |  `"netstandard2.1"`  |


<a id="fable_js_binary"></a>

## fable_js_binary

<pre>
load("@rules_fable//fable:defs.bzl", "fable_js_binary")

fable_js_binary(<a href="#fable_js_binary-name">name</a>, <a href="#fable_js_binary-deps">deps</a>, <a href="#fable_js_binary-binary">binary</a>, <a href="#fable_js_binary-fable_args">fable_args</a>, <a href="#fable_js_binary-package_nupkgs">package_nupkgs</a>, <a href="#fable_js_binary-target_framework">target_framework</a>)
</pre>

Transpiles a fable_binary to JavaScript and exposes its entrypoint for rules_js.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fable_js_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fable_js_binary-deps"></a>deps |  Additional fable_library/fable_binary targets or rules_dotnet NuGet package targets to include only for this transpilation target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_js_binary-binary"></a>binary |  fable_binary target to transpile.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="fable_js_binary-fable_args"></a>fable_args |  Additional command-line arguments passed after the generated fsproj.   | List of strings | optional |  `[]`  |
| <a id="fable_js_binary-package_nupkgs"></a>package_nupkgs |  Extra package nupkgs used as the local NuGet source for project restore.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_js_binary-target_framework"></a>target_framework |  Target framework moniker used to resolve projection-level NuGet deps.   | String | optional |  `"netstandard2.1"`  |


<a id="fable_js_library"></a>

## fable_js_library

<pre>
load("@rules_fable//fable:defs.bzl", "fable_js_library")

fable_js_library(<a href="#fable_js_library-name">name</a>, <a href="#fable_js_library-deps">deps</a>, <a href="#fable_js_library-fable_args">fable_args</a>, <a href="#fable_js_library-library">library</a>, <a href="#fable_js_library-package_nupkgs">package_nupkgs</a>, <a href="#fable_js_library-target_framework">target_framework</a>)
</pre>

Transpiles a fable_library to a JavaScript output directory.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fable_js_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fable_js_library-deps"></a>deps |  Additional fable_library/fable_binary targets or rules_dotnet NuGet package targets to include only for this transpilation target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_js_library-fable_args"></a>fable_args |  Additional command-line arguments passed after the generated fsproj.   | List of strings | optional |  `[]`  |
| <a id="fable_js_library-library"></a>library |  fable_library target to transpile.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="fable_js_library-package_nupkgs"></a>package_nupkgs |  Extra package nupkgs used as the local NuGet source for project restore.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_js_library-target_framework"></a>target_framework |  Target framework moniker used to resolve projection-level NuGet deps.   | String | optional |  `"netstandard2.1"`  |


<a id="fable_py_binary"></a>

## fable_py_binary

<pre>
load("@rules_fable//fable:defs.bzl", "fable_py_binary")

fable_py_binary(<a href="#fable_py_binary-name">name</a>, <a href="#fable_py_binary-deps">deps</a>, <a href="#fable_py_binary-binary">binary</a>, <a href="#fable_py_binary-fable_args">fable_args</a>, <a href="#fable_py_binary-package_nupkgs">package_nupkgs</a>, <a href="#fable_py_binary-target_framework">target_framework</a>)
</pre>

Transpiles a fable_binary to Python and exposes its entrypoint as the default output.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fable_py_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fable_py_binary-deps"></a>deps |  Additional fable_library/fable_binary targets or rules_dotnet NuGet package targets to include only for this transpilation target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_py_binary-binary"></a>binary |  fable_binary target to transpile.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="fable_py_binary-fable_args"></a>fable_args |  Additional command-line arguments passed after the generated fsproj.   | List of strings | optional |  `[]`  |
| <a id="fable_py_binary-package_nupkgs"></a>package_nupkgs |  Extra package nupkgs used as the local NuGet source for project restore.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_py_binary-target_framework"></a>target_framework |  Target framework moniker used to resolve projection-level NuGet deps.   | String | optional |  `"netstandard2.1"`  |


<a id="fable_py_library"></a>

## fable_py_library

<pre>
load("@rules_fable//fable:defs.bzl", "fable_py_library")

fable_py_library(<a href="#fable_py_library-name">name</a>, <a href="#fable_py_library-deps">deps</a>, <a href="#fable_py_library-fable_args">fable_args</a>, <a href="#fable_py_library-library">library</a>, <a href="#fable_py_library-package_nupkgs">package_nupkgs</a>, <a href="#fable_py_library-target_framework">target_framework</a>)
</pre>

Transpiles a fable_library to a Python output directory.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fable_py_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fable_py_library-deps"></a>deps |  Additional fable_library/fable_binary targets or rules_dotnet NuGet package targets to include only for this transpilation target.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_py_library-fable_args"></a>fable_args |  Additional command-line arguments passed after the generated fsproj.   | List of strings | optional |  `[]`  |
| <a id="fable_py_library-library"></a>library |  fable_library target to transpile.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="fable_py_library-package_nupkgs"></a>package_nupkgs |  Extra package nupkgs used as the local NuGet source for project restore.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fable_py_library-target_framework"></a>target_framework |  Target framework moniker used to resolve projection-level NuGet deps.   | String | optional |  `"netstandard2.1"`  |


<a id="fable_toolchain"></a>

## fable_toolchain

<pre>
load("@rules_fable//fable:defs.bzl", "fable_toolchain")

fable_toolchain(<a href="#fable_toolchain-name">name</a>, <a href="#fable_toolchain-fable_tool_nupkg">fable_tool_nupkg</a>, <a href="#fable_toolchain-fable_version">fable_version</a>, <a href="#fable_toolchain-package_nupkgs">package_nupkgs</a>)
</pre>

Defines a Fable compiler toolchain implementation.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fable_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fable_toolchain-fable_tool_nupkg"></a>fable_tool_nupkg |  Fable .NET tool NuGet package.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |
| <a id="fable_toolchain-fable_version"></a>fable_version |  Fable compiler version.   | String | required |  |
| <a id="fable_toolchain-package_nupkgs"></a>package_nupkgs |  Baseline NuGet package artifacts available to generated Fable projects.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |


<a id="fable_library"></a>

## fable_library

<pre>
load("@rules_fable//fable:defs.bzl", "fable_library")

fable_library(<a href="#fable_library-name">name</a>, <a href="#fable_library-kwargs">**kwargs</a>)
</pre>

Collects ordered F# sources and generates an fsproj for Fable.

Also creates a `<name>_lib` alias for BUILD files that use a library-style
naming convention at consumption sites.

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="fable_library-name"></a>name |  <p align="center"> - </p>   |  none |
| <a id="fable_library-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


