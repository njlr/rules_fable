module App

open Fable.Core
open Fable.React
open Feliz
open Browser.Dom
open Browser.Types

[<ReactComponent>]
let Counter() =
  let (count, setCount) = React.useState(0)
  Html.div [
    Html.button [
      prop.style [ style.marginRight 5 ]
      prop.onClick (fun _ -> setCount(count + 1))
      prop.text "+1"
    ]

    Html.button [
      prop.style [ style.marginLeft 5 ]
      prop.onClick (fun _ -> setCount(count - 1))
      prop.text "-1"
    ]

    Html.h1 count
  ]

let root = ReactDOM.createRoot (document.getElementById "root")
root.render (Counter())
