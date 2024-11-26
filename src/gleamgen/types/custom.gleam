import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleamgen/render
import gleamgen/types.{type Unchecked}
import gleamgen/types/variant.{type Variant}

pub type CustomTypeBuilder(repr, variants, generics) {
  CustomTypeBuilder(
    variants: List(Variant(Unchecked)),
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

pub fn new_unchecked(
  _typed_representation: repr,
  variants: List(Variant(Unchecked)),
  generics_list: List(String),
) -> CustomTypeBuilder(repr, a, List(types.GeneratedType(Unchecked))) {
  CustomTypeBuilder(
    variants:,
    generics_list:,
    generics: list.map(generics_list, fn(t) {
      types.generic(t) |> types.to_unchecked
    }),
  )
}

pub fn with_generic(
  old: CustomTypeBuilder(repr, variants, old_generics),
  generic: String,
) -> CustomTypeBuilder(repr, variants, #(old_generics, types.GeneratedType(a))) {
  CustomTypeBuilder(
    variants: old.variants,
    generics: #(old.generics, types.generic(generic)),
    generics_list: [generic, ..old.generics_list],
  )
}

// TODO: with generics unchecked

pub fn with_variant(
  old: CustomTypeBuilder(repr, old, generics),
  variant: fn(generics) -> Variant(new),
) -> CustomTypeBuilder(repr, #(old, new), generics) {
  CustomTypeBuilder(
    variants: [
      old.generics |> variant |> variant.to_unchecked(),
      ..old.variants
    ],
    generics: old.generics,
    generics_list: old.generics_list,
  )
}

pub fn with_unchecked_variants(
  old: CustomTypeBuilder(repr, old, generics),
  variants: fn(generics) -> List(Variant(Unchecked)),
) -> CustomTypeBuilder(repr, Unchecked, generics) {
  CustomTypeBuilder(
    variants: list.append(
      old.generics |> variants |> list.reverse(),
      old.variants,
    ),
    generics: old.generics,
    generics_list: old.generics_list,
  )
}

pub fn to_unchecked(
  old: CustomTypeBuilder(_repr, _, _),
) -> CustomTypeBuilder(Unchecked, Nil, Nil) {
  let CustomTypeBuilder(variants, _, generics_list:) = old
  CustomTypeBuilder(variants:, generics: Nil, generics_list:)
}

pub type CustomType(repr, generics) {
  CustomType(module: option.Option(String), name: String)
}

pub fn to_type(
  input: CustomType(repr, #()),
) -> types.GeneratedType(CustomType(repr, #())) {
  types.custom_type(input.module, input.name, [])
}

pub fn to_type1(
  input: CustomType(repr, Generics1(types.GeneratedType(a))),
  type1: types.GeneratedType(type_a),
) -> types.GeneratedType(
  CustomType(repr, Generics1(types.GeneratedType(type_a))),
) {
  types.custom_type(input.module, input.name, [type1 |> types.to_unchecked()])
}

pub fn to_type2(
  input: CustomType(
    repr,
    Generics2(types.GeneratedType(a), types.GeneratedType(b)),
  ),
  type1: types.GeneratedType(type_a),
  type2: types.GeneratedType(type_b),
) -> types.GeneratedType(
  CustomType(
    repr,
    Generics2(types.GeneratedType(type_a), types.GeneratedType(type_b)),
  ),
) {
  types.custom_type(input.module, input.name, [
    type1 |> types.to_unchecked(),
    type2 |> types.to_unchecked(),
  ])
}

pub fn to_type3(
  input: CustomType(
    repr,
    Generics3(
      types.GeneratedType(a),
      types.GeneratedType(b),
      types.GeneratedType(c),
    ),
  ),
  type1: types.GeneratedType(type_a),
  type2: types.GeneratedType(type_b),
  type3: types.GeneratedType(type_c),
) -> types.GeneratedType(
  CustomType(
    repr,
    Generics3(
      types.GeneratedType(type_a),
      types.GeneratedType(type_b),
      types.GeneratedType(type_c),
    ),
  ),
) {
  types.custom_type(input.module, input.name, [
    type1 |> types.to_unchecked(),
    type2 |> types.to_unchecked(),
    type3 |> types.to_unchecked(),
  ])
}

pub fn to_type4(
  input: CustomType(
    repr,
    Generics4(
      types.GeneratedType(a),
      types.GeneratedType(b),
      types.GeneratedType(c),
      types.GeneratedType(d),
    ),
  ),
  type1: types.GeneratedType(type_a),
  type2: types.GeneratedType(type_b),
  type3: types.GeneratedType(type_c),
  type4: types.GeneratedType(type_d),
) -> types.GeneratedType(
  CustomType(
    repr,
    Generics4(
      types.GeneratedType(type_a),
      types.GeneratedType(type_b),
      types.GeneratedType(type_c),
      types.GeneratedType(type_d),
    ),
  ),
) {
  types.custom_type(input.module, input.name, [
    type1 |> types.to_unchecked(),
    type2 |> types.to_unchecked(),
    type3 |> types.to_unchecked(),
    type4 |> types.to_unchecked(),
  ])
}

pub fn to_type5(
  input: CustomType(
    repr,
    Generics5(
      types.GeneratedType(a),
      types.GeneratedType(b),
      types.GeneratedType(c),
      types.GeneratedType(d),
      types.GeneratedType(e),
    ),
  ),
  type1: types.GeneratedType(type_a),
  type2: types.GeneratedType(type_b),
  type3: types.GeneratedType(type_c),
  type4: types.GeneratedType(type_d),
  type5: types.GeneratedType(type_e),
) -> types.GeneratedType(
  CustomType(
    repr,
    Generics5(
      types.GeneratedType(type_a),
      types.GeneratedType(type_b),
      types.GeneratedType(type_c),
      types.GeneratedType(type_d),
      types.GeneratedType(type_e),
    ),
  ),
) {
  types.custom_type(input.module, input.name, [
    type1 |> types.to_unchecked(),
    type2 |> types.to_unchecked(),
    type3 |> types.to_unchecked(),
    type4 |> types.to_unchecked(),
    type5 |> types.to_unchecked(),
  ])
}

pub fn render(
  type_: CustomTypeBuilder(repr, variants, generics),
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
              let rendered = types.render_type(arg.1)
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
