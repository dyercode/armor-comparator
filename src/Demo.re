let defaultTo = (prop, defined) => {
  switch (Js.Nullable.toOption(prop)) {
  | Some(p) => p
  | None => defined
  };
};

let plusify = num => {
  let numberText = string_of_int(num);
  num >= 0 ? "+" ++ numberText : numberText;
};
