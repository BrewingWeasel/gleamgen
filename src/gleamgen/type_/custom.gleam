import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleamgen/internal/import_reference
import gleamgen/internal/render
import gleamgen/type_.{type Dynamic}
import gleamgen/type_/variant.{type Variant}

pub type CustomTypeBuilder(repr, variants, generics) {
  CustomTypeBuilder(
    variants: List(Variant(Dynamic)),
    generics_list: List(String),
    generics: generics,
  )
}

pub type Generics1(a) =
  #(#(), a)

pub type Generics2(a, b) =
  #(#(#(), a), b)

pub type Generics3(a, b, c) =
  #(#(#(#(), a), b), c)

pub type Generics4(a, b, c, d) =
  #(#(#(#(#(), a), b), c), d)

pub type Generics5(a, b, c, d, e) =
  #(#(#(#(#(#(), a), b), c), d), e)

pub type Generics6(a, b, c, d, e, f) =
  #(#(#(#(#(#(#(), a), b), c), d), e), f)

pub type Generics7(a, b, c, d, e, f, g) =
  #(#(#(#(#(#(#(#(), a), b), c), d), e), f), g)

pub type Generics8(a, b, c, d, e, f, g, h) =
  #(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h)

pub type Generics9(a, b, c, d, e, f, g, h, i) =
  #(#(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h), i)

pub fn new(_typed_representation: a) -> CustomTypeBuilder(a, #(), #()) {
  CustomTypeBuilder(variants: [], generics: #(), generics_list: [])
}

pub fn new_dynamic(
  _typed_representation: repr,
  variants: List(Variant(Dynamic)),
  generics_list: List(String),
) -> CustomTypeBuilder(repr, a, List(type_.GeneratedType(Dynamic))) {
  CustomTypeBuilder(
    variants:,
    generics_list:,
    generics: list.map(generics_list, fn(t) {
      type_.generic(t) |> type_.to_dynamic
    }),
  )
}

pub fn with_generic(
  old: CustomTypeBuilder(repr, variants, old_generics),
  generic: String,
) -> CustomTypeBuilder(repr, variants, #(old_generics, type_.GeneratedType(a))) {
  CustomTypeBuilder(
    variants: old.variants,
    generics: #(old.generics, type_.generic(generic)),
    generics_list: [generic, ..old.generics_list],
  )
}

// TODO: with generics dynamic

pub fn with_variant(
  old: CustomTypeBuilder(repr, old, generics),
  variant: fn(generics) -> Variant(new),
) -> CustomTypeBuilder(repr, #(old, new), generics) {
  CustomTypeBuilder(
    variants: [old.generics |> variant |> variant.to_dynamic(), ..old.variants],
    generics: old.generics,
    generics_list: old.generics_list,
  )
}

pub fn with_dynamic_variants(
  old: CustomTypeBuilder(repr, old, generics),
  variants: fn(generics) -> List(Variant(Dynamic)),
) -> CustomTypeBuilder(repr, Dynamic, generics) {
  CustomTypeBuilder(
    variants: list.append(
      old.generics |> variants |> list.reverse(),
      old.variants,
    ),
    generics: old.generics,
    generics_list: old.generics_list,
  )
}

pub fn to_dynamic(
  old: CustomTypeBuilder(_repr, _, _),
) -> CustomTypeBuilder(Dynamic, Nil, Nil) {
  let CustomTypeBuilder(variants, _, generics_list:) = old
  CustomTypeBuilder(variants:, generics: Nil, generics_list:)
}

pub type CustomType(repr, generics) {
  CustomType(
    module: option.Option(import_reference.ImportReference),
    name: String,
  )
}

pub fn to_type(
  input: CustomType(repr, #()),
) -> type_.GeneratedType(CustomType(repr, #())) {
  type_.custom_type(input.module, input.name, [])
}

pub fn to_type1(
  input: CustomType(repr, Generics1(type_.GeneratedType(a))),
  type1: type_.GeneratedType(type_a),
) -> type_.GeneratedType(
  CustomType(repr, Generics1(type_.GeneratedType(type_a))),
) {
  type_.custom_type(input.module, input.name, [type1 |> type_.to_dynamic()])
}

pub fn to_type2(
  input: CustomType(
    repr,
    Generics2(type_.GeneratedType(a), type_.GeneratedType(b)),
  ),
  type1: type_.GeneratedType(type_a),
  type2: type_.GeneratedType(type_b),
) -> type_.GeneratedType(
  CustomType(
    repr,
    Generics2(type_.GeneratedType(type_a), type_.GeneratedType(type_b)),
  ),
) {
  type_.custom_type(input.module, input.name, [
    type1 |> type_.to_dynamic(),
    type2 |> type_.to_dynamic(),
  ])
}

pub fn to_type3(
  input: CustomType(
    repr,
    Generics3(
      type_.GeneratedType(a),
      type_.GeneratedType(b),
      type_.GeneratedType(c),
    ),
  ),
  type1: type_.GeneratedType(type_a),
  type2: type_.GeneratedType(type_b),
  type3: type_.GeneratedType(type_c),
) -> type_.GeneratedType(
  CustomType(
    repr,
    Generics3(
      type_.GeneratedType(type_a),
      type_.GeneratedType(type_b),
      type_.GeneratedType(type_c),
    ),
  ),
) {
  type_.custom_type(input.module, input.name, [
    type1 |> type_.to_dynamic(),
    type2 |> type_.to_dynamic(),
    type3 |> type_.to_dynamic(),
  ])
}

pub fn to_type4(
  input: CustomType(
    repr,
    Generics4(
      type_.GeneratedType(a),
      type_.GeneratedType(b),
      type_.GeneratedType(c),
      type_.GeneratedType(d),
    ),
  ),
  type1: type_.GeneratedType(type_a),
  type2: type_.GeneratedType(type_b),
  type3: type_.GeneratedType(type_c),
  type4: type_.GeneratedType(type_d),
) -> type_.GeneratedType(
  CustomType(
    repr,
    Generics4(
      type_.GeneratedType(type_a),
      type_.GeneratedType(type_b),
      type_.GeneratedType(type_c),
      type_.GeneratedType(type_d),
    ),
  ),
) {
  type_.custom_type(input.module, input.name, [
    type1 |> type_.to_dynamic(),
    type2 |> type_.to_dynamic(),
    type3 |> type_.to_dynamic(),
    type4 |> type_.to_dynamic(),
  ])
}

pub fn to_type5(
  input: CustomType(
    repr,
    Generics5(
      type_.GeneratedType(a),
      type_.GeneratedType(b),
      type_.GeneratedType(c),
      type_.GeneratedType(d),
      type_.GeneratedType(e),
    ),
  ),
  type1: type_.GeneratedType(type_a),
  type2: type_.GeneratedType(type_b),
  type3: type_.GeneratedType(type_c),
  type4: type_.GeneratedType(type_d),
  type5: type_.GeneratedType(type_e),
) -> type_.GeneratedType(
  CustomType(
    repr,
    Generics5(
      type_.GeneratedType(type_a),
      type_.GeneratedType(type_b),
      type_.GeneratedType(type_c),
      type_.GeneratedType(type_d),
      type_.GeneratedType(type_e),
    ),
  ),
) {
  type_.custom_type(input.module, input.name, [
    type1 |> type_.to_dynamic(),
    type2 |> type_.to_dynamic(),
    type3 |> type_.to_dynamic(),
    type4 |> type_.to_dynamic(),
    type5 |> type_.to_dynamic(),
  ])
}

pub fn render(
  type_: CustomTypeBuilder(repr, variants, generics),
  context: render.Context,
) -> render.Rendered {
  let #(details, variants) =
    type_.variants
    |> list.reverse()
    |> list.map_fold(render.empty_details, fn(old_details, var) {
      let #(details, variant) = case var.arguments {
        [] -> #(render.empty_details, doc.empty)
        _ -> {
          let #(details, arguments) =
            var.arguments
            |> list.reverse()
            |> list.map_fold(render.empty_details, fn(acc_details, arg) {
              let rendered = type_.render_type(arg.1, context)
              let type_doc =
                rendered
                |> result.map(fn(v) { v.doc })
                |> result.unwrap(doc.from_string("??"))
              let details = case rendered {
                Ok(render.Render(details:, ..)) ->
                  render.merge_details(acc_details, details)
                Error(_) -> acc_details
              }
              let doc = case arg.0 {
                option.None -> type_doc
                option.Some(name) ->
                  doc.concat([
                    doc.from_string(name),
                    doc.from_string(":"),
                    doc.space,
                    type_doc,
                  ])
                  |> doc.group()
              }
              #(details, doc)
            })
          #(details, arguments |> render.pretty_list())
        }
      }
      #(
        render.merge_details(old_details, details),
        doc.from_string(var.name)
          |> doc.append(variant),
      )
    })

  variants
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
  |> render.Render(details:)
}
