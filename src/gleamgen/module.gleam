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
  CustomType(custom.CustomType(Unchecked, Nil, Nil))
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
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: Constant(value |> expression.to_unchecked())),
      ..rest.definitions
    ],
  )
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
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: Function(func |> function.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type1(
  details: DefinitionDetails,
  type_: custom.CustomType(repr, #(#(), a), generics),
  handler: fn(types.GeneratedType(repr), constructor.Construtor(repr, a)) ->
    Module,
) -> Module {
  let assert [variant1] = type_.variants
  let rest =
    handler(types.unchecked_ident(details.name), constructor.new(variant1))
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type2(
  details: DefinitionDetails,
  type_: custom.CustomType(repr, #(#(#(), a), b), generics),
  handler: fn(
    types.GeneratedType(repr),
    constructor.Construtor(repr, a),
    constructor.Construtor(repr, b),
  ) ->
    Module,
) -> Module {
  let assert [variant2, variant1] = type_.variants
  let rest =
    handler(
      types.unchecked_ident(details.name),
      constructor.new(variant1),
      constructor.new(variant2),
    )
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type3(
  details: DefinitionDetails,
  type_: custom.CustomType(repr, #(#(#(), a), b, c), generics),
  handler: fn(
    types.GeneratedType(repr),
    constructor.Construtor(repr, a),
    constructor.Construtor(repr, b),
    constructor.Construtor(repr, c),
  ) ->
    Module,
) -> Module {
  let assert [variant3, variant2, variant1] = type_.variants
  let rest =
    handler(
      types.unchecked_ident(details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
    )
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type4(
  details: DefinitionDetails,
  type_: custom.CustomType(repr, #(#(#(#(), a), b), c, d), generics),
  handler: fn(
    types.GeneratedType(repr),
    constructor.Construtor(repr, a),
    constructor.Construtor(repr, b),
    constructor.Construtor(repr, c),
    constructor.Construtor(repr, d),
  ) ->
    Module,
) -> Module {
  let assert [variant4, variant3, variant2, variant1] = type_.variants
  let rest =
    handler(
      types.unchecked_ident(details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
    )
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type5(
  details: DefinitionDetails,
  type_: custom.CustomType(repr, #(#(#(#(#(), a), b), c), d, e), generics),
  handler: fn(
    types.GeneratedType(repr),
    constructor.Construtor(repr, a),
    constructor.Construtor(repr, b),
    constructor.Construtor(repr, c),
    constructor.Construtor(repr, d),
    constructor.Construtor(repr, e),
  ) ->
    Module,
) -> Module {
  let assert [variant5, variant4, variant3, variant2, variant1] = type_.variants
  let rest =
    handler(
      types.unchecked_ident(details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
    )
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type6(
  details: DefinitionDetails,
  type_: custom.CustomType(repr, #(#(#(#(#(#(), a), b), c), d), e, f), generics),
  handler: fn(
    types.GeneratedType(repr),
    constructor.Construtor(repr, a),
    constructor.Construtor(repr, b),
    constructor.Construtor(repr, c),
    constructor.Construtor(repr, d),
    constructor.Construtor(repr, e),
    constructor.Construtor(repr, f),
  ) ->
    Module,
) -> Module {
  let assert [variant6, variant5, variant4, variant3, variant2, variant1] =
    type_.variants
  let rest =
    handler(
      types.unchecked_ident(details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
      constructor.new(variant6),
    )
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type7(
  details: DefinitionDetails,
  type_: custom.CustomType(
    repr,
    #(#(#(#(#(#(#(), a), b), c), d), e), f, g),
    generics,
  ),
  handler: fn(
    types.GeneratedType(repr),
    constructor.Construtor(repr, a),
    constructor.Construtor(repr, b),
    constructor.Construtor(repr, c),
    constructor.Construtor(repr, d),
    constructor.Construtor(repr, e),
    constructor.Construtor(repr, f),
    constructor.Construtor(repr, g),
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
      types.unchecked_ident(details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
      constructor.new(variant6),
      constructor.new(variant7),
    )
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type8(
  details: DefinitionDetails,
  type_: custom.CustomType(
    repr,
    #(#(#(#(#(#(#(#(), a), b), c), d), e), f), g, h),
    generics,
  ),
  handler: fn(
    types.GeneratedType(repr),
    constructor.Construtor(repr, a),
    constructor.Construtor(repr, b),
    constructor.Construtor(repr, c),
    constructor.Construtor(repr, d),
    constructor.Construtor(repr, e),
    constructor.Construtor(repr, f),
    constructor.Construtor(repr, g),
    constructor.Construtor(repr, h),
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
      types.unchecked_ident(details.name),
      constructor.new(variant1),
      constructor.new(variant2),
      constructor.new(variant3),
      constructor.new(variant4),
      constructor.new(variant5),
      constructor.new(variant6),
      constructor.new(variant7),
      constructor.new(variant8),
    )
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type9(
  details: DefinitionDetails,
  type_: custom.CustomType(
    repr,
    #(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h, i),
    generics,
  ),
  handler: fn(
    types.GeneratedType(repr),
    constructor.Construtor(repr, a),
    constructor.Construtor(repr, b),
    constructor.Construtor(repr, c),
    constructor.Construtor(repr, d),
    constructor.Construtor(repr, e),
    constructor.Construtor(repr, f),
    constructor.Construtor(repr, g),
    constructor.Construtor(repr, h),
    constructor.Construtor(repr, i),
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
      types.unchecked_ident(details.name),
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
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type_unchecked(
  details: DefinitionDetails,
  type_: custom.CustomType(repr, Unchecked, generics),
  handler: fn(
    types.GeneratedType(repr),
    List(constructor.Construtor(repr, Unchecked)),
  ) ->
    Module,
) -> Module {
  let rest =
    handler(
      types.unchecked_ident(details.name),
      type_.variants |> list.reverse() |> list.map(constructor.new),
    )
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_type_alias(
  details: DefinitionDetails,
  type_: types.GeneratedType(repr),
  handler: fn(types.GeneratedType(repr)) -> Module,
) -> Module {
  let rest = handler(types.unchecked_ident(details.name))
  Module(
    ..rest,
    definitions: [
      Definition(details:, value: TypeAlias(type_ |> types.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn eof() -> Module {
  Module([], [])
}

pub fn render(module: Module, context: render.Context) -> render.Rendered {
  let rendered_defs =
    list.map(module.definitions, fn(def) {
      doc.join(list.map(def.details.attributes, render_attribute), doc.line)
      |> doc.append(case list.is_empty(def.details.attributes) {
        True -> doc.empty
        False -> doc.line
      })
      |> doc.append(case def.details.is_public {
        True -> doc.concat([doc.from_string("pub"), doc.space])
        False -> doc.empty
      })
      |> doc.append(case def.value {
        Constant(value) ->
          doc.concat([
            doc.from_string("const "),
            doc.from_string(def.details.name),
            doc.space,
            doc.from_string("="),
            doc.space,
            expression.render(value, context).doc,
          ])
        CustomType(type_) ->
          doc.concat([
            doc.from_string("type "),
            doc.from_string(def.details.name),
            custom.render(type_).doc,
          ])
        TypeAlias(type_) ->
          doc.concat([
            doc.from_string("type "),
            doc.from_string(def.details.name),
            doc.space,
            doc.from_string("="),
            doc.space,
            types.render_type(type_)
              |> result.map(fn(v) { v.doc })
              |> result.unwrap(doc.from_string("??")),
          ])
        Function(func) -> render_function(func, context, def.details.name).doc
      })
    })

  let rendered_imports =
    module.imports
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
  |> render.Render
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
  doc.concat([
    doc.from_string("fn "),
    doc.from_string(name),
    rendered_args,
    doc.space,
    case types.render_type(func.returns) {
      Ok(returned) ->
        doc.concat([doc.from_string("->"), doc.space, returned.doc, doc.space])
      Error(_) -> doc.empty
    },
    render.body(
      expression.render(
        func.body,
        render.Context(..context, include_brackets_current_level: False),
      ).doc,
      force_newlines: True,
    ),
  ])
  |> render.Render
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
  |> render.Render
}
