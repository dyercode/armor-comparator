@bs.scope("JSON") @bs.val
external parseArmors: string => array<Model.armor> = "parse"

@bs.scope("JSON") @bs.val
external parseCharacter: string => Model.character = "parse"

let defaultTo = (prop, defined) =>
  switch Js.Nullable.toOption(prop) {
  | Some(p) => p
  | None => defined
  }

let plusify = num => {
  let numberText = string_of_int(num)
  num >= 0 ? "+" ++ numberText : numberText
}

type order =
  | Ascending
  | Descending

let fetchCharacter = {
  Dom.Storage.localStorage |> Dom.Storage.getItem("character")
}

let parse = (data, parser) => {
  try {
    Some(parser(data))
  } catch {
  | Js.Exn.Error(obj) =>
    switch Js.Exn.message(obj) {
    | Some(m) => Js.log("problem parsing character from storage" ++ m)
    | None => ()
    }
    None
  }
}

let loadCharacter = () => {
  switch fetchCharacter {
  | Some(s) => parse(s, parseCharacter)->Belt.Option.getWithDefault(Model.defaultCharacter)
  | None => Model.defaultCharacter
  }
}

let loadArmors = () => {
  switch Dom.Storage.localStorage |> Dom.Storage.getItem("armors") {
  | Some(s) => parse(s, parseArmors)->Belt.Option.getWithDefault([])
  | None => []
  }
}
