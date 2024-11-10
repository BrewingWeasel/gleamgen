import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleamgen/render
import gleamgen/types.{type Unchecked}
import gleamgen/types/variant.{type Variant}

pub type CustomType(repr, variants) {
  CustomType(variants: List(Variant(Unchecked)))
}

pub fn new(_typed_representation: a) -> CustomType(a, #()) {
  CustomType(variants: [])
}

pub fn new_unchecked(
  _typed_representation: repr,
  variants: List(Variant(Unchecked)),
) -> CustomType(repr, a) {
  CustomType(variants:)
}

pub fn with_variant(
  old: CustomType(repr, old),
  variant: Variant(new),
) -> CustomType(repr, #(old, new)) {
  CustomType(variants: [variant |> variant.to_unchecked(), ..old.variants])
}

pub fn to_unchecked(old: CustomType(_repr, _)) -> CustomType(Unchecked, Nil) {
  let CustomType(variants) = old
  CustomType(variants:)
}

pub fn render(type_: CustomType(repr, variants)) -> render.Rendered {
  type_.variants
  |> list.reverse()
  |> list.map(fn(var) {
    doc.from_string(var.name)
    |> doc.append(
      var.arguments
      |> list.reverse()
      |> list.map(fn(arg) {
        case arg.0 {
          option.None ->
            types.render_type(arg.1)
            |> result.map(fn(v) { v.doc })
            |> result.unwrap(doc.from_string("??"))
          option.Some(name) ->
            doc.concat([
              doc.from_string(name),
              doc.from_string(":"),
              doc.space,
              types.render_type(arg.1)
                |> result.map(fn(v) { v.doc })
                |> result.unwrap(doc.from_string("??")),
            ])
        }
      })
      |> render.pretty_list(),
    )
  })
  |> doc.join(doc.line)
  |> render.body(force_newlines: True)
  |> render.Render
}
