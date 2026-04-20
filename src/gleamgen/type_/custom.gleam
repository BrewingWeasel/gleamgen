import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleamgen/internal/import_reference
import gleamgen/internal/render
import gleamgen/type_.{type Dynamic}
import gleamgen/type_/variant.{type Variant}

/// Define a custom type.
/// Once you have built the type, add it to the module with [`module.with_custom_type`](module#with_custom_type1).
/// If you want to add type safety to an imported type, use [`module.with_imported_custom_type`](module#with_imported_custom_type1).
///
/// ```gleam
/// let animals =
///   custom.new()
///   |> custom.with_variant(fn(_) {
///     variant.new("Dog")
///     |> variant.with_argument(option.Some("bones"), type_.int)
///   })
///   |> custom.with_variant(fn(_) {
///     variant.new("Cat")
///     |> variant.with_argument(option.Some("name"), type_.string)
///     |> variant.with_argument(option.Some("has_catnip"), type_.bool)
///   })
/// use animal_type, dog_constructor, cat_constructor <- module.with_custom_type2(
///   definition.new("Animal") |> definition.with_publicity(True),
///   animals,
/// )
/// ```
///
/// To create, see [`new`](#new), [`with_generic`](#with_generic), and [`with_variant`](#with_variant).
pub type CustomTypeBuilder(repr, variants, generics) {
  CustomTypeBuilder(
    variants: List(Variant(Dynamic)),
    generics_list: List(String),
    generics: generics,
  )
}

/// Represents the generics of a custom type with 1 generic parameter.
pub type Generics1(a) =
  #(#(), a)

/// Represents the generics of a custom type with 2 generic parameters.
pub type Generics2(a, b) =
  #(#(#(), a), b)

/// Represents the generics of a custom type with 3 generic parameters.
pub type Generics3(a, b, c) =
  #(#(#(#(), a), b), c)

/// Represents the generics of a custom type with 4 generic parameters.
pub type Generics4(a, b, c, d) =
  #(#(#(#(#(), a), b), c), d)

/// Represents the generics of a custom type with 5 generic parameters.
pub type Generics5(a, b, c, d, e) =
  #(#(#(#(#(#(), a), b), c), d), e)

/// Represents the generics of a custom type with 6 generic parameters.
pub type Generics6(a, b, c, d, e, f) =
  #(#(#(#(#(#(#(), a), b), c), d), e), f)

/// Represents the generics of a custom type with 7 generic parameters.
pub type Generics7(a, b, c, d, e, f, g) =
  #(#(#(#(#(#(#(#(), a), b), c), d), e), f), g)

/// Represents the generics of a custom type with 8 generic parameters.
pub type Generics8(a, b, c, d, e, f, g, h) =
  #(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h)

/// Represents the generics of a custom type with 9 generic parameters.
pub type Generics9(a, b, c, d, e, f, g, h, i) =
  #(#(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h), i)

/// Create a new [`CustomTypeBuilder`](#CustomTypeBuilder).
/// See also [`new_dynamic`](#new_dynamic) for creating a custom type from a dynamic list of variants and generics.
pub fn new() -> CustomTypeBuilder(typed_representation, #(), #()) {
  CustomTypeBuilder(variants: [], generics: #(), generics_list: [])
}

pub fn new_dynamic(
  variants: List(Variant(Dynamic)),
  generics_list: List(String),
) -> CustomTypeBuilder(
  repr,
  typed_representation,
  List(type_.GeneratedType(Dynamic)),
) {
  CustomTypeBuilder(
    variants:,
    generics_list:,
    generics: list.map(generics_list, fn(t) {
      type_.generic(t) |> type_.to_dynamic
    }),
  )
}

/// Add a generic type parameter to the custom type.
/// ```gleam
/// let my_option =
///   custom.new()
///   |> custom.with_generic("a")
///   |> custom.with_variant(fn(generics) {
///     let #(#(), a) = generics
///     variant.new("MySome")
///     |> variant.with_argument(option.None, a)
///   })
///   |> custom.with_variant(fn(_generics) {
///     variant.new("MyNone")
///   })
/// use my_option_type, my_some_constructor, my_none_constructor <- module.with_custom_type2(
///   definition.new("MyOption"),
///   my_option,
/// )
/// ```
pub fn with_generic(
  old: CustomTypeBuilder(repr, variants, old_generics),
  generic: String,
) -> CustomTypeBuilder(repr, variants, #(old_generics, type_.GeneratedType(a))) {
  CustomTypeBuilder(
    ..old,
    generics: #(old.generics, type_.generic(generic)),
    generics_list: [generic, ..old.generics_list],
  )
}

// TODO: with generics dynamic

/// Add a variant the custom type, given its generics (see [`with_generic`](#with_generic)).
/// See also [`with_dynamic_variants`](#with_dynamic_variants) for adding multiple variants at once.
///
/// ```gleam
/// custom.new()
/// |> custom.with_variant(fn(_) {
///   variant.new("Dog")
///   |> variant.with_argument(option.Some("bones"), type_.int)
/// })
/// |> custom.with_variant(fn(_) {
///   variant.new("Cat")
///   |> variant.with_argument(option.Some("name"), type_.string)
///   |> variant.with_argument(option.Some("has_catnip"), type_.bool)
/// })
/// ```
pub fn with_variant(
  old: CustomTypeBuilder(repr, old, generics),
  variant: fn(generics) -> Variant(new),
) -> CustomTypeBuilder(repr, #(old, new), generics) {
  CustomTypeBuilder(..old, variants: [
    old.generics |> variant |> variant.to_dynamic(),
    ..old.variants
  ])
}

/// Add a dynamic list of variants to the custom type, given its generics (see [`with_generic`](#with_generic)).
pub fn with_dynamic_variants(
  old: CustomTypeBuilder(repr, old, generics),
  variants: fn(generics) -> List(Variant(Dynamic)),
) -> CustomTypeBuilder(repr, Dynamic, generics) {
  CustomTypeBuilder(
    ..old,
    variants: list.append(
      old.generics |> variants |> list.reverse(),
      old.variants,
    ),
  )
}

pub fn to_dynamic(
  old: CustomTypeBuilder(_repr, _, _),
) -> CustomTypeBuilder(Dynamic, Nil, Nil) {
  CustomTypeBuilder(..old, generics: Nil)
}

pub opaque type CustomType(repr, generics) {
  CustomType(
    module: option.Option(import_reference.ImportReference),
    name: String,
  )
}

@internal
pub fn new_custom_type(module, name) -> CustomType(repr, generics) {
  CustomType(module:, name:)
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
      let #(details, variant) = case variant.get_arguments(var) {
        [] -> #(render.empty_details, doc.empty)
        _ -> {
          let #(details, arguments) =
            variant.get_arguments(var)
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
        doc.from_string(variant.get_name(var))
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
