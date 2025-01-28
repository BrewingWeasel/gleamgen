import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleamgen/expression.{type Expression}
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/import_
import gleamgen/render
import gleamgen/types.{type Unchecked}
import gleamgen/types/custom

pub type Definition {
  Definition(details: DefinitionDetails, value: Definable)
}

pub type Attribute {
  ExternalErlang
  ExternalJavascript
  Deprecated(String)
  Internal
}

pub type DefinitionDetails {
  DefinitionDetails(name: String, is_public: Bool, attributes: List(Attribute))
}

pub type Definable {
  Function(function.Function(Unchecked, Unchecked))
  CustomTypeBuilder(custom.CustomTypeBuilder(Unchecked, Nil, Nil))
  Constant(Expression(Unchecked))
  TypeAlias(types.GeneratedType(Unchecked))
}

pub type Module {
  Module(definitions: List(Definition), imports: List(import_.ImportedModule))
}

pub fn with_constant(
  details: DefinitionDetails,
  value: Expression(t),
  handler: fn(Expression(t)) -> Module,
) -> Module {
  let rest = handler(expression.unchecked_ident(details.name))
  Module(..rest, definitions: [
    Definition(details:, value: Constant(value |> expression.to_unchecked())),
    ..rest.definitions
  ])
}

pub fn with_import(
  module: import_.ImportedModule,
  handler: fn(import_.ImportedModule) -> Module,
) -> Module {
  let rest = handler(module)
  Module(..rest, imports: [module, ..rest.imports])
}

pub fn with_imports_unchecked(
  modules: List(import_.ImportedModule),
  handler: fn(List(import_.ImportedModule)) -> Module,
) -> Module {
  let rest = handler(modules)
  Module(..rest, imports: list.append(list.reverse(modules), rest.imports))
}

pub fn with_function(
  details: DefinitionDetails,
  func: function.Function(func_type, ret),
  handler: fn(Expression(func_type)) -> Module,
) -> Module {
  let rest = handler(expression.unchecked_ident(details.name))
  Module(..rest, definitions: [
    Definition(details:, value: Function(func |> function.to_unchecked())),
    ..rest.definitions
  ])
}

pub fn with_custom_type1(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(repr, custom.Generics1(a), generics),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
  ) ->
    Module,
) -> Module {
  let assert [variant1] = type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

// {{{

pub fn with_custom_type2(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(repr, custom.Generics2(a, b), generics),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
    constructor.Constructor(repr, b, generics),
  ) ->
    Module,
) -> Module {
  let assert [variant2, variant1] = type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
      constructor.new(variant2),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

pub fn with_custom_type3(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(repr, custom.Generics3(a, b, c), generics),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
    constructor.Constructor(repr, b, generics),
    constructor.Constructor(repr, c, generics),
  ) ->
    Module,
) -> Module {
  let assert [variant3, variant2, variant1] = type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

pub fn with_custom_type4(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(repr, custom.Generics4(a, b, c, d), generics),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
    constructor.Constructor(repr, b, generics),
    constructor.Constructor(repr, c, generics),
    constructor.Constructor(repr, d, generics),
  ) ->
    Module,
) -> Module {
  let assert [variant4, variant3, variant2, variant1] = type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

pub fn with_custom_type5(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(
    repr,
    custom.Generics5(a, b, c, d, e),
    generics,
  ),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
    constructor.Constructor(repr, b, generics),
    constructor.Constructor(repr, c, generics),
    constructor.Constructor(repr, d, generics),
    constructor.Constructor(repr, e, generics),
  ) ->
    Module,
) -> Module {
  let assert [variant5, variant4, variant3, variant2, variant1] = type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

pub fn with_custom_type6(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(
    repr,
    custom.Generics6(a, b, c, d, e, f),
    generics,
  ),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
    constructor.Constructor(repr, b, generics),
    constructor.Constructor(repr, c, generics),
    constructor.Constructor(repr, d, generics),
    constructor.Constructor(repr, e, generics),
    constructor.Constructor(repr, f, generics),
  ) ->
    Module,
) -> Module {
  let assert [variant6, variant5, variant4, variant3, variant2, variant1] =
    type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
      constructor.new(variant6),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

pub fn with_custom_type7(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(
    repr,
    custom.Generics7(a, b, c, d, e, f, g),
    generics,
  ),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
    constructor.Constructor(repr, b, generics),
    constructor.Constructor(repr, c, generics),
    constructor.Constructor(repr, d, generics),
    constructor.Constructor(repr, e, generics),
    constructor.Constructor(repr, f, generics),
    constructor.Constructor(repr, g, generics),
  ) ->
    Module,
) -> Module {
  let assert [
    variant7,
    variant6,
    variant5,
    variant4,
    variant3,
    variant2,
    variant1,
  ] = type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
      constructor.new(variant6),
      constructor.new(variant7),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

pub fn with_custom_type8(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(
    repr,
    custom.Generics8(a, b, c, d, e, f, g, h),
    generics,
  ),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
    constructor.Constructor(repr, b, generics),
    constructor.Constructor(repr, c, generics),
    constructor.Constructor(repr, d, generics),
    constructor.Constructor(repr, e, generics),
    constructor.Constructor(repr, f, generics),
    constructor.Constructor(repr, g, generics),
    constructor.Constructor(repr, h, generics),
  ) ->
    Module,
) -> Module {
  let assert [
    variant8,
    variant7,
    variant6,
    variant5,
    variant4,
    variant3,
    variant2,
    variant1,
  ] = type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
      constructor.new(variant6),
      constructor.new(variant7),
      constructor.new(variant8),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

pub fn with_custom_type9(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(
    repr,
    custom.Generics9(a, b, c, d, e, f, g, h, i),
    generics,
  ),
  handler: fn(
    custom.CustomType(repr, generics),
    constructor.Constructor(repr, a, generics),
    constructor.Constructor(repr, b, generics),
    constructor.Constructor(repr, c, generics),
    constructor.Constructor(repr, d, generics),
    constructor.Constructor(repr, e, generics),
    constructor.Constructor(repr, f, generics),
    constructor.Constructor(repr, g, generics),
    constructor.Constructor(repr, h, generics),
    constructor.Constructor(repr, i, generics),
  ) ->
    Module,
) -> Module {
  let assert [
    variant9,
    variant8,
    variant7,
    variant6,
    variant5,
    variant4,
    variant3,
    variant2,
    variant1,
  ] = type_.variants
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
      constructor.new(variant6),
      constructor.new(variant7),
      constructor.new(variant8),
      constructor.new(variant9),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

// }}}

pub fn with_custom_type_unchecked(
  details: DefinitionDetails,
  type_: custom.CustomTypeBuilder(repr, Unchecked, generics),
  handler: fn(
    custom.CustomType(repr, generics),
    List(constructor.Constructor(repr, Unchecked, generics)),
  ) ->
    Module,
) -> Module {
  let rest =
    handler(
      custom.CustomType(option.None, details.name),
      type_.variants |> list.reverse() |> list.map(constructor.new),
    )
  Module(..rest, definitions: [
    Definition(
      details:,
      value: CustomTypeBuilder(type_ |> custom.to_unchecked()),
    ),
    ..rest.definitions
  ])
}

pub fn with_type_alias(
  details: DefinitionDetails,
  type_: types.GeneratedType(repr),
  handler: fn(types.GeneratedType(repr)) -> Module,
) -> Module {
  let rest = handler(types.unchecked_ident(details.name))
  Module(..rest, definitions: [
    Definition(details:, value: TypeAlias(type_ |> types.to_unchecked())),
    ..rest.definitions
  ])
}

pub fn eof() -> Module {
  Module([], [])
}

pub fn render(module: Module, context: render.Context) -> render.Rendered {
  let #(details, rendered_defs) =
    list.map_fold(
      module.definitions,
      render.empty_details,
      fn(previous_details, def) {
        let #(definition, details) = case def.value {
          Constant(value) -> {
            let rendered_expr = expression.render(value, context)
            #(
              doc.concat([
                doc.from_string("const "),
                doc.from_string(def.details.name),
                doc.space,
                doc.from_string("="),
                doc.space,
                rendered_expr.doc,
              ]),
              rendered_expr.details,
            )
          }
          CustomTypeBuilder(type_) -> {
            let rendered_type = custom.render(type_)
            #(
              doc.concat([
                doc.from_string("type "),
                doc.from_string(def.details.name),
                rendered_type.doc,
              ]),
              rendered_type.details,
            )
          }
          TypeAlias(type_) -> {
            let rendered_type = types.render_type(type_)
            #(
              doc.concat([
                doc.from_string("type "),
                doc.from_string(def.details.name),
                doc.space,
                doc.from_string("="),
                doc.space,
                rendered_type
                  |> result.map(fn(v) { v.doc })
                  |> result.unwrap(doc.from_string("??")),
              ]),
              rendered_type
                |> result.map(fn(v) { v.details })
                |> result.unwrap(render.empty_details),
            )
          }
          Function(func) -> {
            let rendered = render_function(func, context, def.details.name)
            #(rendered.doc, rendered.details)
          }
        }

        let full_doc =
          doc.join(list.map(def.details.attributes, render_attribute), doc.line)
          |> doc.append(case list.is_empty(def.details.attributes) {
            True -> doc.empty
            False -> doc.line
          })
          |> doc.append(case def.details.is_public {
            True -> doc.concat([doc.from_string("pub"), doc.space])
            False -> doc.empty
          })
          |> doc.append(definition)

        #(render.merge_details(details, previous_details), full_doc)
      },
    )

  let rendered_imports =
    module.imports
    |> list.filter(fn(m) {
      details.used_imports
      |> list.contains(import_.get_reference(m))
    })
    |> list.map(fn(x) { x |> render_imported_module |> render.to_string() })
    |> list.sort(string.compare)
    |> list.map(doc.from_string)
    |> doc.join(with: doc.line)
    |> doc.append(case list.is_empty(module.imports) {
      True -> doc.empty
      False -> doc.concat([doc.line, doc.line])
    })

  rendered_imports
  |> doc.append(doc.concat_join(rendered_defs, [doc.line, doc.line]))
  |> render.Render(details:)
}

fn render_attribute(attribute: Attribute) -> doc.Document {
  case attribute {
    ExternalErlang -> doc.from_string("@external(erlang)")
    ExternalJavascript -> doc.from_string("@external(javascript)")
    Deprecated(reason) ->
      doc.concat([
        doc.from_string("@deprecated(\""),
        doc.from_string(reason),
        doc.from_string("\")"),
      ])
    Internal -> doc.from_string("@internal")
  }
}

pub fn render_function(
  func: function.Function(_, _),
  context: render.Context,
  name: String,
) -> render.Rendered {
  let rendered_args =
    func.args
    |> list.map(expression.render_attribute(_, context))
    |> render.pretty_list()

  let rendered_type = types.render_type(func.returns)
  let rendered_body =
    expression.render(
      func.body,
      render.Context(..context, include_brackets_current_level: False),
    )

  doc.concat([
    doc.from_string("fn "),
    doc.from_string(name),
    rendered_args,
    doc.space,
    case rendered_type {
      Ok(returned) ->
        doc.concat([doc.from_string("->"), doc.space, returned.doc, doc.space])
      Error(_) -> doc.empty
    },
    render.body(rendered_body.doc, force_newlines: True),
  ])
  |> render.Render(details: render.merge_details(
    rendered_type
      |> result.map(fn(t) { t.details })
      |> result.unwrap(render.empty_details),
    rendered_body.details,
  ))
}

pub fn render_imported_module(module: import_.ImportedModule) -> render.Rendered {
  doc.concat([
    doc.from_string("import "),
    doc.from_string(string.join(module.name, "/")),
    case module.alias {
      option.Some(alias) ->
        doc.concat([
          doc.space,
          doc.from_string("as"),
          doc.space,
          doc.from_string(alias),
        ])
      option.None -> doc.empty
    },
  ])
  |> render.Render(details: render.empty_details)
}
