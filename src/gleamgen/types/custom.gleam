import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleamgen/render
import gleamgen/types.{type Unchecked}
import gleamgen/types/variant.{type Variant}

pub type CustomType(repr, variants, generics) {
  CustomType(
    variants: List(Variant(Unchecked)),
    generics_list: List(String),
    generics: generics,
  )
}

pub fn new(_typed_representation: a) -> CustomType(a, #(), #()) {
  CustomType(variants: [], generics: #(), generics_list: [])
}

pub fn new_unchecked(
  _typed_representation: repr,
  variants: List(Variant(Unchecked)),
  generics_list: List(String),
) -> CustomType(repr, a, List(types.GeneratedType(Unchecked))) {
  CustomType(
    variants:,
    generics_list:,
    generics: list.map(generics_list, fn(t) {
      types.generic(t) |> types.to_unchecked
    }),
  )
}

pub fn with_generic(
  old: CustomType(repr, variants, old_generics),
  generic: String,
) -> CustomType(repr, variants, #(old_generics, types.GeneratedType(Unchecked))) {
  CustomType(
    variants: old.variants,
    generics: #(old.generics, types.generic(generic)),
    generics_list: [generic, ..old.generics_list],
  )
}

// TODO: with generics unchecked

pub fn with_variant(
  old: CustomType(repr, old, generics),
  variant: fn(generics) -> Variant(new),
) -> CustomType(repr, #(old, new), generics) {
  CustomType(
    variants: [
      old.generics |> variant |> variant.to_unchecked(),
      ..old.variants
    ],
    generics: old.generics,
    generics_list: old.generics_list,
  )
}

pub fn with_unchecked_variants(
  old: CustomType(repr, old, generics),
  variants: fn(generics) -> List(Variant(Unchecked)),
) -> CustomType(repr, Unchecked, generics) {
  CustomType(
    variants: list.append(
      old.generics |> variants |> list.reverse(),
      old.variants,
    ),
    generics: old.generics,
    generics_list: old.generics_list,
  )
}

pub fn to_unchecked(
  old: CustomType(_repr, _, _),
) -> CustomType(Unchecked, Nil, Nil) {
  let CustomType(variants, _, generics_list:) = old
  CustomType(variants:, generics: Nil, generics_list:)
}

pub fn render(type_: CustomType(repr, variants, generics)) -> render.Rendered {
  type_.variants
  |> list.reverse()
  |> list.map(fn(var) {
    doc.from_string(var.name)
    |> doc.append(case var.arguments {
      [] -> doc.empty
      _ ->
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
              |> doc.group()
          }
        })
        |> render.pretty_list()
    })
  })
  |> doc.join(doc.line)
  |> render.body(force_newlines: True)
  |> doc.prepend(
    doc.concat([
      case type_.generics_list {
        [] -> doc.empty
        generics ->
          generics
          |> list.reverse()
          |> list.map(doc.from_string)
          |> render.pretty_list()
      },
      doc.space,
    ]),
  )
  |> render.Render
}
