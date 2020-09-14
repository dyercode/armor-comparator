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

let asc = Ascending
let desc = Descending

let numericSort = (left: int, right: int, order: order): int => {
  let orderMultiplier = switch order {
  | Ascending => 1
  | Descending => -1
  }
  left == right ? 0 : (left > right ? 1 : -1) * orderMultiplier
}
