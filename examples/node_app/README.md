# Fable Node.js Console App

This example uses `rules_fable` to transpile F# to JavaScript and
`rules_nodejs` to provide the hermetic Node.js runtime used to execute it.

```sh
bazel run //:console_app
```

Expected output:

```text
Hello from Fable, Node.js!
```
