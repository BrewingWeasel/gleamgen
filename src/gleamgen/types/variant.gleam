import gleam/option.{type Option}
import gleamgen/types.{type Unchecked}

pub type Variant(a) {
  Variant(
    name: String,
    arguments: List(#(Option(String), types.GeneratedType(Unchecked))),
  )
}

pub fn new(name: String) -> Variant(#()) {
  Variant(name:, arguments: [])
}

pub fn with_argument(
  old: Variant(old),
  name: Option(String),
  type_: types.GeneratedType(argument),
) -> Variant(#(old, argument)) {
  Variant(name: old.name, arguments: [
    #(name, type_ |> types.to_unchecked()),
    ..old.arguments
  ])
}

pub fn to_unchecked(variant: Variant(a)) -> Variant(Unchecked) {
  let Variant(name, args) = variant
  Variant(name, args)
}
