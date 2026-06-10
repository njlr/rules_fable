module Isomorphic.App

open Thoth.Json.Core

#if FABLE_COMPILER_PYTHON
open Thoth.Json.Python
#else
#if FABLE_COMPILER
open Thoth.Json.JavaScript
#else
open Thoth.Json.System.Text.Json
#endif
#endif

open Isomorphic
open Isomorphic.Thoth

[<EntryPoint>]
let main argv =
  let book =
    {
      Title = "The Great Gatsby"
      Author = "F. Scott Fitzgerald"
    }

  let json =
    book
    |> Book.encode
    |> Encode.toString 2

  printfn "%s" json

  0
