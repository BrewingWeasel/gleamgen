import glam/doc
import glance
import gleam/bool
import gleam/dict
import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import gleamgen/expression.{type Expression}
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/import_
import gleamgen/internal/module_text
import gleamgen/module/definition
import gleamgen/render
import gleamgen/types.{type Unchecked}
import gleamgen/types/custom

pub opaque type ExternalModule {
  ExternalModule(
    module: Option(glance.Module),
    definitions: List(ModuleDefinition),
    parse_error: Option(glance.Error),
  )
}

pub type Module {
  Module(
    definitions: List(ModuleDefinition),
    imports: List(import_.ImportedModule),
    external_module: Option(ExternalModule),
  )
}

type PredefinedDefinition {
  PredefinedImport(glance.Definition(glance.Import))
  PredefinedCustomType(glance.Definition(glance.CustomType))
  PredefinedTypeAlias(glance.Definition(glance.TypeAlias))
  PredefinedConstant(glance.Definition(glance.Constant))
  PredefinedFunction(glance.Definition(glance.Function))
}

pub type ModuleDefinition {
  Definition(details: definition.Definition, value: Definable)
}

pub opaque type Definable {
  Function(function.Function(Unchecked, Unchecked))
  CustomTypeBuilder(custom.CustomTypeBuilder(Unchecked, Nil, Nil))
  Constant(Expression(Unchecked))
  TypeAlias(types.GeneratedType(Unchecked))
  Predefined(ast: PredefinedDefinition, text_before: String, content: String)
}

fn arrange_definitions(
  module: glance.Module,
  module_text: module_text.ModuleText,
) {
  let get_location = fn(definition: PredefinedDefinition) {
    case definition {
      PredefinedImport(def) -> def.definition.location
      PredefinedConstant(def) -> def.definition.location
      PredefinedCustomType(def) -> def.definition.location
      PredefinedTypeAlias(def) -> def.definition.location
      PredefinedFunction(def) -> def.definition.location
    }
  }

  let #(module, _module_text) =
    [
      list.map(module.imports, PredefinedImport),
      list.map(module.constants, PredefinedConstant),
      list.map(module.custom_types, PredefinedCustomType),
      list.map(module.type_aliases, PredefinedTypeAlias),
      list.map(module.functions, PredefinedFunction),
    ]
    |> list.flatten()
    |> list.sort(fn(first, second) {
      int.compare(get_location(first).start, get_location(second).start)
    })
    |> module_text.fold(
      module_text,
      Module(
        [],
        [],
        option.Some(ExternalModule(option.Some(module), [], option.None)),
      ),
      handle_existing_definition,
      get_location,
    )
  module
}

fn handle_existing_definition(
  predefined_definition: PredefinedDefinition,
  module: Module,
  before_text: String,
  definition_text: String,
) -> Module {
  let add_definition = fn(name, publicity, attributes) {
    let external_module =
      module.external_module
      |> option.unwrap(ExternalModule(option.None, [], option.None))

    let is_public = case publicity {
      glance.Public -> True
      glance.Private -> False
    }
    let attributes =
      list.filter_map(attributes, definition.attribute_from_glance)

    let details =
      definition.new(name)
      |> definition.with_publicity(is_public)
      |> definition.with_attributes(attributes)
      |> definition.with_text_before(before_text)
      |> definition.set_predefined(True)

    let new_definition =
      Definition(
        details:,
        value: Predefined(predefined_definition, before_text, definition_text),
      )

    Module(
      ..module,
      external_module: option.Some(
        ExternalModule(..external_module, definitions: [
          new_definition,
          ..external_module.definitions
        ]),
      ),
    )
  }

  case predefined_definition {
    PredefinedImport(definition) -> {
      let new_import = import_.convert_import(definition, before_text)
      Module(..module, imports: [new_import, ..module.imports])
    }
    PredefinedConstant(definition) ->
      add_definition(
        definition.definition.name,
        definition.definition.publicity,
        definition.attributes,
      )
    PredefinedCustomType(definition) ->
      add_definition(
        definition.definition.name,
        definition.definition.publicity,
        definition.attributes,
      )
    PredefinedTypeAlias(definition) ->
      add_definition(
        definition.definition.name,
        definition.definition.publicity,
        definition.attributes,
      )
    PredefinedFunction(definition) ->
      add_definition(
        definition.definition.name,
        definition.definition.publicity,
        definition.attributes,
      )
  }
}

pub fn from_string(module_text: String) -> Module {
  case glance.module(module_text) {
    Ok(parsed_module) -> {
      let module_text = module_text.from_string(module_text)
      arrange_definitions(parsed_module, module_text)
    }
    Error(err) -> {
      Module(
        [],
        [],
        option.Some(ExternalModule(option.None, [], option.Some(err))),
      )
    }
  }
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

pub fn replace_function(
  function_name: String,
  module: Module,
  func: fn(Option(glance.Function)) -> function.Function(func_type, ret),
  handler: fn(Module, Expression(func_type)) -> Module,
) -> Module {
  let rest = handler(module, expression.unchecked_ident(function_name))
  case module.external_module {
    option.Some(ExternalModule(definitions:, ..) as external_module) -> {
      let definitions =
        list.map(definitions, fn(definition) {
          use <- bool.guard(
            definition.details.name != function_name,
            definition,
          )
          let #(details, value) = case definition.value {
            Predefined(PredefinedFunction(f), _, _) -> #(
              definition.details |> definition.set_predefined(False),
              Function(
                func(option.Some(f.definition)) |> function.to_unchecked(),
              ),
            )
            v -> #(definition.details, v)
          }
          Definition(details:, value:)
        })

      Module(
        ..module,
        external_module: option.Some(
          ExternalModule(..external_module, definitions:),
        ),
      )
    }
    option.None -> {
      Module(..rest, definitions: [
        Definition(
          definition.new(function_name),
          value: Function(func(option.None) |> function.to_unchecked()),
        ),
        ..rest.definitions
      ])
    }
  }
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
  let #(definitions_at_top, definitions_at_bottom, definitions_after) =
    separate_definitions(module.definitions, [], [], dict.new())

  let external_definitions = case module.external_module {
    option.Some(external) -> external.definitions
    option.None -> []
  }
  let all_definitions =
    [
      definitions_at_bottom,
      external_definitions,
      definitions_at_top,
    ]
    |> list.flatten
    |> list.reverse()

  let #(details, rendered_defs) =
    render_all_definitions(
      all_definitions,
      definitions_after,
      option.None,
      context,
      render.empty_details,
      [],
    )

  let rendered_imports =
    module.imports
    |> list.filter(fn(m) {
      m.predefined
      || details.used_imports
      |> list.contains(import_.get_reference(m))
    })
    |> list.sort(import_.compare)
    |> import_.merge_imports
    |> list.map(fn(x) { x |> render_imported_module |> render.to_string() })
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
    doc.from_string(module.before_text),
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
  context: render.Context,
  previous_details: render.RenderedDetails,
  rendered_definitions: List(doc.Document),
) -> #(render.RenderedDetails, List(doc.Document)) {
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
          #(previous_details, list.reverse(rendered_definitions))
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
    Predefined(_, _, content) -> {
      #(doc.from_string(content), render.empty_details)
    }
  }

  let full_doc =
    doc.concat([
      doc.from_string(definition.details.text_before),
      doc.join(
        list.map(definition.details.attributes, definition.render_attribute),
        doc.line,
      ),
    ])
    |> doc.append(case list.is_empty(definition.details.attributes) {
      True -> doc.empty
      False -> doc.line
    })
    |> doc.append(
      case definition.details.is_public && !definition.details.predefined {
        True -> doc.concat([doc.from_string("pub"), doc.space])
        False -> doc.empty
      },
    )
    |> doc.append(rendered)

  #(full_doc, details)
}
