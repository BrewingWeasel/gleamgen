import glam/doc
import gleam/list
import gleam/option
import gleam/string
import gleamgen/expression.{type Expression}
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/import_
import gleamgen/render
import gleamgen/types.{type Unchecked}
import gleamgen/types/custom

pub type Definition {
  Definition(attributes: DefinitionAttributes, value: Definable)
}

pub type Decorator {
  ExternalErlang
  ExternalJavascript
  Deprecated(String)
  Internal
}

pub type DefinitionAttributes {
  DefinitionAttributes(
    name: String,
    is_public: Bool,
    decorators: List(Decorator),
  )
}

pub type Definable {
  Function(function.Function(Unchecked, Unchecked))
  CustomType(custom.CustomType(Unchecked, Nil))
  Constant(Expression(Unchecked))
}

pub type Module {
  Module(definitions: List(Definition), imports: List(import_.ImportedModule))
}

pub fn with_constant(
  attributes: DefinitionAttributes,
  value: Expression(t),
  handler: fn(Expression(t)) -> Module,
) -> Module {
  let rest = handler(expression.unchecked_ident(attributes.name))
  Module(
    ..rest,
    definitions: [
      Definition(
        attributes:,
        value: Constant(value |> expression.to_unchecked()),
      ),
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

pub fn with_function(
  attributes: DefinitionAttributes,
  func: function.Function(func_type, ret),
  handler: fn(Expression(func_type)) -> Module,
) -> Module {
  let rest = handler(expression.unchecked_ident(attributes.name))
  Module(
    ..rest,
    definitions: [
      Definition(attributes:, value: Function(func |> function.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type2(
  attributes: DefinitionAttributes,
  type_: custom.CustomType(repr, #(#(#(), a), b)),
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
      types.unchecked_ident(attributes.name),
      constructor.new(variant1),
      constructor.new(variant2),
    )
  Module(
    ..rest,
    definitions: [
      Definition(attributes:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type_unchecked(
  attributes: DefinitionAttributes,
  type_: custom.CustomType(repr, Unchecked),
  handler: fn(
    types.GeneratedType(repr),
    List(constructor.Construtor(repr, Unchecked)),
  ) ->
    Module,
) -> Module {
  let rest =
    handler(
      types.unchecked_ident(attributes.name),
      type_.variants |> list.reverse() |> list.map(constructor.new),
    )
  Module(
    ..rest,
    definitions: [
      Definition(attributes:, value: CustomType(type_ |> custom.to_unchecked())),
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
      doc.join(list.map(def.attributes.decorators, render_decorator), doc.line)
      |> doc.append(case list.is_empty(def.attributes.decorators) {
        True -> doc.empty
        False -> doc.line
      })
      |> doc.append(case def.attributes.is_public {
        True -> doc.concat([doc.from_string("pub"), doc.space])
        False -> doc.empty
      })
      |> doc.append(case def.value {
        Constant(value) ->
          doc.concat([
            doc.from_string("const "),
            doc.from_string(def.attributes.name),
            doc.space,
            doc.from_string("="),
            doc.space,
            expression.render(value, context).doc,
          ])
        CustomType(type_) ->
          doc.concat([
            doc.from_string("type "),
            doc.from_string(def.attributes.name),
            doc.space,
            custom.render(type_).doc,
          ])
        Function(func) ->
          render_function(func, context, def.attributes.name).doc
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

fn render_decorator(decorator: Decorator) -> doc.Document {
  case decorator {
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
