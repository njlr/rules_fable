namespace Isomorphic

type Book =
  {
    Title : string
    Author : string
  }

module Thoth =

  open Thoth.Json.Core

  [<RequireQualifiedAccess>]
  module Book =

    let encode : Encoder<Book> =
      fun (book: Book) ->
        Encode.object
          [
            "title", Encode.string book.Title
            "author", Encode.string book.Author
          ]

    let decode : Decoder<Book> =
      Decode.object
        (fun get ->
          {
            Title = get.Required.Field "title" Decode.string
            Author = get.Required.Field "author" Decode.string
          }
        )
