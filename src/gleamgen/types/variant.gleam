import gleam/list
import gleam/option.{type Option}
import gleamgen/types.{type Dynamic}

pub type Variant(a) {
  Variant(
    name: String,
    arguments: List(#(Option(String), types.GeneratedType(Dynamic))),
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
    #(name, type_ |> types.to_dynamic()),
    ..old.arguments
  ])
}

pub fn with_arguments_dynamic(
  old: Variant(old),
  variants: List(#(Option(String), types.GeneratedType(Dynamic))),
) -> Variant(Dynamic) {
  Variant(
    name: old.name,
    arguments: list.append(list.reverse(variants), old.arguments),
  )
}

pub fn to_dynamic(variant: Variant(a)) -> Variant(Dynamic) {
  let Variant(name, args) = variant
  Variant(name, args)
}
