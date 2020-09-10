Js.log("Hello, BuckleScript and Reason!");

let defaultTo = (prop, defined) => {
  switch (Js.Nullable.toOption(prop)) {
  | Some(p) => p
  | None => defined
  };
};

let plusify = num => {
  num >= 0 ? "+" ++ string_of_int(num) : string_of_int(num);
};
