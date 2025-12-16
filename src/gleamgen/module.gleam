import glam/doc
import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleamgen/expression.{type Expression}
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/import_
import gleamgen/module/definition
import gleamgen/render
import gleamgen/types.{type Unchecked}
import gleamgen/types/custom


pub type Module {
  Module(
    definitions: List(ModuleDefinition),
    imports: List(import_.ImportedModule),
  )
}

pub type ModuleDefinition {
  Definition(details: definition.Definition, value: Definable)
}

pub opaque type Definable {
  Function(function.Function(Unchecked, Unchecked))
  CustomTypeBuilder(custom.CustomTypeBuilder(Unchecked, Nil, Nil))
  Constant(Expression(Unchecked))
  TypeAlias(types.GeneratedType(Unchecked))
}

pub fn with_constant(
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  details: definition.Definition,
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
  Module([], [], option.None)
}

pub fn render(module: Module, context: render.Context) -> render.Rendered {
  let #(details, rendered_defs) =
    list.map_fold(
      module.definitions,
      render.empty_details,
      fn(previous_details, definition) {
        let #(rendered, new_details) = render_definition(definition, context)
        #(render.merge_details(previous_details, new_details), rendered)
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

fn render_all_definitions(
  definitions: List(ModuleDefinition),
  after_definition: dict.Dict(String, List(ModuleDefinition)),
  last_definition_name: Option(String),
  context,
  previous_details,
  rendered_definitions,
) {
  let definitions_to_prepend =
    last_definition_name
    |> option.then(fn(name) {
      case dict.get(after_definition, name) {
        Ok(defs) -> option.Some(#(defs, dict.delete(after_definition, name)))
        Error(_) -> option.None
      }
    })

  case definitions_to_prepend {
    option.Some(#(defs, new_after_definition)) -> {
      render_all_definitions(
        list.append(defs, definitions),
        new_after_definition,
        option.None,
        context,
        previous_details,
        rendered_definitions,
      )
    }
    option.None -> {
      case definitions {
        [definition, ..rest] -> {
          let #(rendered_def, new_details) =
            render_definition(definition, context)

          render_all_definitions(
            rest,
            after_definition,
            option.Some(definition.details.name),
            context,
            render.merge_details(previous_details, new_details),
            [rendered_def, ..rendered_definitions],
          )
        }
        [] -> {
          #(list.reverse(rendered_definitions), previous_details)
        }
      }
    }
  }
}

fn separate_definitions(
  definitions: List(ModuleDefinition),
  at_top: List(ModuleDefinition),
  at_bottom: List(ModuleDefinition),
  after_definition: dict.Dict(String, List(ModuleDefinition)),
) -> #(
  List(ModuleDefinition),
  List(ModuleDefinition),
  dict.Dict(String, List(ModuleDefinition)),
) {
  case definitions {
    [definition, ..rest] -> {
      case definition.details.position {
        definition.Top ->
          separate_definitions(
            rest,
            [definition, ..at_top],
            at_bottom,
            after_definition,
          )
        definition.Bottom ->
          separate_definitions(
            rest,
            at_top,
            [definition, ..at_bottom],
            after_definition,
          )
        definition.AfterDefinition(def_name) -> {
          let after_definition =
            dict.upsert(
              after_definition,
              def_name,
              with: fn(currently_after_definition) {
                case currently_after_definition {
                  option.Some(list) -> [definition, ..list]
                  option.None -> [definition]
                }
              },
            )

          separate_definitions(rest, at_top, at_bottom, after_definition)
        }
      }
    }
    [] -> #(at_top, at_bottom, after_definition)
  }
}

fn render_definition(definition: ModuleDefinition, context) {
  let #(rendered, details) = case definition.value {
    Constant(value) -> {
      let rendered_expr = expression.render(value, context)
      #(
        doc.concat([
          doc.from_string("const "),
          doc.from_string(definition.details.name),
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
          doc.from_string(definition.details.name),
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
          doc.from_string(definition.details.name),
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
      let rendered =
        function.render(func, context, option.Some(definition.details.name))
      #(rendered.doc, rendered.details)
    }
  }

  let full_doc =
    doc.join(
      list.map(definition.details.attributes, definition.render_attribute),
      doc.line,
    )
    |> doc.append(case list.is_empty(definition.details.attributes) {
      True -> doc.empty
      False -> doc.line
    })
    |> doc.append(case definition.details.is_public {
      True -> doc.concat([doc.from_string("pub"), doc.space])
      False -> doc.empty
    })
    |> doc.append(rendered)

  #(full_doc, details)
}
