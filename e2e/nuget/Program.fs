open Thoth.Json.Core

#if FABLE_COMPILER
open Thoth.Json.JavaScript
#else
open Thoth.Json.System.Text.Json
#endif

[<EntryPoint>]
let main argv =
  let json =
    Encode.object
      [
        "message", Encode.string "Hello, world."
      ]
    |> Encode.toString 2
  printfn "%s" json
  0
