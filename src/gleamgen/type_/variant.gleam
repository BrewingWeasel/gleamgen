import gleam/list
import gleam/option.{type Option}
import gleamgen/type_.{type Dynamic}

pub opaque type Variant(a) {
  Variant(
    name: String,
    arguments: List(#(Option(String), type_.GeneratedType(Dynamic))),
  )
}

pub fn new(name: String) -> Variant(#()) {
  Variant(name:, arguments: [])
}

pub fn with_argument(
  old: Variant(old),
  name: Option(String),
  type_: type_.GeneratedType(argument),
) -> Variant(#(old, argument)) {
  Variant(name: old.name, arguments: [
    #(name, type_ |> type_.to_dynamic()),
    ..old.arguments
  ])
}

pub fn with_arguments_dynamic(
  old: Variant(old),
  variants: List(#(Option(String), type_.GeneratedType(Dynamic))),
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

pub fn get_name(variant: Variant(a)) -> String {
  variant.name
}

pub fn get_arguments(
  variant: Variant(a),
) -> List(#(Option(String), type_.GeneratedType(Dynamic))) {
  variant.arguments
}
