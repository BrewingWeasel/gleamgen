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
  Definition(name: String, value: Definable)
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
  name: String,
  value: Expression(t),
  handler: fn(Expression(t)) -> Module,
) -> Module {
  let rest = handler(expression.unchecked_ident(name))
  Module(
    ..rest,
    definitions: [
      Definition(name:, value: Constant(value |> expression.to_unchecked())),
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
  name: String,
  func: function.Function(func_type, ret),
  handler: fn(Expression(func_type)) -> Module,
) -> Module {
  let rest = handler(expression.unchecked_ident(name))
  Module(
    ..rest,
    definitions: [
      Definition(name:, value: Function(func |> function.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type2(
  name: String,
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
      types.unchecked_ident(name),
      constructor.new(variant1),
      constructor.new(variant2),
    )
  Module(
    ..rest,
    definitions: [
      Definition(name:, value: CustomType(type_ |> custom.to_unchecked())),
      ..rest.definitions
    ],
  )
}

pub fn with_custom_type_unchecked(
  name: String,
  type_: custom.CustomType(repr, Unchecked),
  handler: fn(
    types.GeneratedType(repr),
    List(constructor.Construtor(repr, Unchecked)),
  ) ->
    Module,
) -> Module {
  let rest =
    handler(
      types.unchecked_ident(name),
      type_.variants |> list.reverse() |> list.map(constructor.new),
    )
  Module(
    ..rest,
    definitions: [
      Definition(name:, value: CustomType(type_ |> custom.to_unchecked())),
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
      case def.value {
        Constant(value) ->
          doc.concat([
            doc.from_string("pub const "),
            doc.from_string(def.name),
            doc.space,
            doc.from_string("="),
            doc.space,
            expression.render(value, context).doc,
          ])
        CustomType(type_) ->
          doc.concat([
            doc.from_string("pub type "),
            doc.from_string(def.name),
            doc.space,
            custom.render(type_).doc,
          ])
        Function(func) -> render_function(func, context, def.name).doc
      }
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
    doc.from_string("pub fn "),
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
