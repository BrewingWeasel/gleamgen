import glance
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/string
import gleamgen/expression.{type Expression}
import gleamgen/function
import gleamgen/types
import gleamgen/types/custom

/// One entry in an `import path.{ … }` exposing list.
pub type ExposedItem {
  /// Renders as `type name` or `type name as alias`.
  ExposedType(name: String, alias: Option(String))
  /// Renders as `name` or `name as alias`.
  ExposedValue(name: String, alias: Option(String))
}

pub type ImportedModule {
  ImportedModule(
    name: List(String),
    alias: Option(String),
    exposing: List(ExposedItem),
    before_text: String,
    predefined: Bool,
  )
}

pub fn new(name: List(String)) -> ImportedModule {
  ImportedModule(
    name: name,
    alias: option.None,
    exposing: [],
    before_text: "",
    predefined: False,
  )
}

pub fn with_alias(imported: ImportedModule, alias: String) -> ImportedModule {
  ImportedModule(..imported, alias: option.Some(alias))
}

pub fn with_exposing(
  imported: ImportedModule,
  exposing: List(ExposedItem),
) -> ImportedModule {
  ImportedModule(..imported, exposing: exposing)
}

/// When `True`, the import line is always emitted even if static analysis finds
/// no reference to the module prefix (e.g. types only nested inside other ASTs).
pub fn with_predefined(
  imported: ImportedModule,
  predefined: Bool,
) -> ImportedModule {
  ImportedModule(..imported, predefined: predefined)
}

pub fn exposed_type(name: String) -> ExposedItem {
  ExposedType(name, option.None)
}

pub fn exposed_type_as(name: String, alias: String) -> ExposedItem {
  ExposedType(name, option.Some(alias))
}

pub fn exposed_value(name: String) -> ExposedItem {
  ExposedValue(name, option.None)
}

pub fn exposed_value_as(name: String, alias: String) -> ExposedItem {
  ExposedValue(name, option.Some(alias))
}

@internal
pub fn get_reference(imported: ImportedModule) -> String {
  case imported.alias {
    option.Some(alias) -> alias
    option.None -> {
      let assert Ok(name) = imported.name |> list.last
      name
    }
  }
}

pub fn raw_ident(imported: ImportedModule, name: String) -> Expression(any) {
  expression.raw(get_reference(imported) <> "." <> name)
}

pub fn value_of_type(
  imported: ImportedModule,
  name: String,
  type_: types.GeneratedType(t),
) -> Expression(t) {
  expression.raw_of_type(get_reference(imported) <> "." <> name, type_)
}

pub fn raw_type(
  imported: ImportedModule,
  name: String,
) -> custom.CustomType(t, generics) {
  custom.CustomType(option.Some(get_reference(imported)), name)
}

/// Import an existing function from the module.
/// Useful for importing functions and automatically getting their types
/// Note that the function does not check if the provided function actually exists in the module.
/// ```gleam
/// let dict_module = import_.new(["gleam", "dict"])
/// let dict_new = import_.function1(dict_module, dict.new)
/// // dict.new ^ is a reference to actual function from gleam/dict
/// // Therefore this type checks:
/// expression.call0(dict_new)
/// // but this does not:
/// expression.call1(dict_new, expression.int(46))
/// ```
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function0(
  imported: ImportedModule,
  func: fn() -> ret,
) -> Expression(fn() -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// Useful for importing functions and automatically getting their types
/// Note that the function does not check if the provided function actually exists in the module.
/// ```gleam
/// let io_module = import_.new(["gleam", "io"])
/// let io_println = import_.function1(io_module, io.println)
/// // io.println ^ is a reference to actual function from gleam/io
/// // Therefore this type checks:
/// expression.call1(io_println, expression.string("Hello, World!"))
/// // but this does not:
/// expression.call1(io_println, expression.int(46))
/// ```
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function1(
  imported: ImportedModule,
  func: fn(a) -> ret,
) -> Expression(fn(a) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

// rest of the repetitive functionN functions
// {{{

/// Import an existing function from the module.
/// See `function1` for more details.
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function2(
  imported: ImportedModule,
  func: fn(a, b) -> ret,
) -> Expression(fn(a, b) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function3(
  imported: ImportedModule,
  func: fn(a, b, c) -> ret,
) -> Expression(fn(a, b, c) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function4(
  imported: ImportedModule,
  func: fn(a, b, c, d) -> ret,
) -> Expression(fn(a, b, c, d) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function5(
  imported: ImportedModule,
  func: fn(a, b, c, d, e) -> ret,
) -> Expression(fn(a, b, c, d, e) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function6(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f) -> ret,
) -> Expression(fn(a, b, c, d, e, f) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function7(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f, g) -> ret,
) -> Expression(fn(a, b, c, d, e, f, g) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function8(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f, g, h) -> ret,
) -> Expression(fn(a, b, c, d, e, f, g, h) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
@deprecated("use import_.value_of_type and types.reference instead")
pub fn function9(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f, g, h, i) -> ret,
) -> Expression(fn(a, b, c, d, e, f, g, h, i) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

// }}}

// @internal
// pub fn convert_glance_imports(
//   imports: List(glance.Definition(glance.Import)),
//   text: ModuleText,
// ) -> #(List(ImportedModule), ModuleText) {
//   // TODO: preserve order if import statements broken up
//   imports
//   |> list.reverse()
//   |> module_text.fold(text, convert_import, fn(mod) { mod.definition.location })
// }

@internal
pub fn convert_import(
  definition: glance.Definition(glance.Import),
  before_import: String,
) -> ImportedModule {
  // TODO: unqualified values and types
  let glance.Import(module:, alias:, ..) = definition.definition
  let name = string.split(module, "/")
  let alias =
    option.map(alias, fn(a) {
      case a {
        glance.Named(n) -> n
        glance.Discarded(n) -> n
      }
    })

  ImportedModule(
    name:,
    alias: alias,
    exposing: [],
    before_text: before_import,
    predefined: True,
  )
}

@internal
pub fn compare(
  imported_module: ImportedModule,
  imported_module_2: ImportedModule,
) -> order.Order {
  string.compare(
    string.join(imported_module.name, "/"),
    string.join(imported_module_2.name, "/"),
  )
}

pub fn merge_imports(imports) {
  do_merge_imports(imports, option.None, [])
}

fn compare_optional_string(a: Option(String), b: Option(String)) -> order.Order {
  case a, b {
    option.None, option.None -> order.Eq
    option.None, option.Some(_) -> order.Lt
    option.Some(_), option.None -> order.Gt
    option.Some(x), option.Some(y) -> string.compare(x, y)
  }
}

fn compare_exposed_item(a: ExposedItem, b: ExposedItem) -> order.Order {
  case a, b {
    ExposedType(..), ExposedValue(..) -> order.Lt
    ExposedValue(..), ExposedType(..) -> order.Gt
    ExposedType(n1, a1), ExposedType(n2, a2) ->
      case string.compare(n1, n2) {
        order.Eq -> compare_optional_string(a1, a2)
        o -> o
      }
    ExposedValue(n1, a1), ExposedValue(n2, a2) ->
      case string.compare(n1, n2) {
        order.Eq -> compare_optional_string(a1, a2)
        o -> o
      }
  }
}

fn render_exposed_item(item: ExposedItem) -> String {
  case item {
    ExposedType(name, alias) ->
      case alias {
        option.None -> "type " <> name
        option.Some(a) -> "type " <> name <> " as " <> a
      }
    ExposedValue(name, alias) ->
      case alias {
        option.None -> name
        option.Some(a) -> name <> " as " <> a
      }
  }
}

@internal
pub fn exposing_to_string(items: List(ExposedItem)) -> String {
  items
  |> list.map(render_exposed_item)
  |> string.join(", ")
}

/// Combine exposing lists when `merge_imports` collapses duplicate module paths
/// (sorted and deduplicated).
fn merge_exposing_lists(
  a: List(ExposedItem),
  b: List(ExposedItem),
) -> List(ExposedItem) {
  list.append(a, b)
  |> list.sort(compare_exposed_item)
  |> list.unique
}

fn do_merge_imports(
  imports_left: List(ImportedModule),
  last_import: Option(ImportedModule),
  acc: List(ImportedModule),
) {
  case imports_left, last_import {
    [import_, ..rest], option.Some(last) if last.name == import_.name -> {
      let new_import =
        ImportedModule(
          name: import_.name,
          alias: case last.alias, import_.alias {
            option.Some(_), _ -> last.alias
            option.None, option.Some(a) -> option.Some(a)
            option.None, option.None -> option.None
          },
          exposing: merge_exposing_lists(last.exposing, import_.exposing),
          before_text: last.before_text <> import_.before_text,
          predefined: last.predefined || import_.predefined,
        )
      do_merge_imports(rest, option.Some(new_import), acc)
    }
    [import_, ..rest], option.Some(last) ->
      do_merge_imports(rest, option.Some(import_), [last, ..acc])
    [import_, ..rest], option.None ->
      do_merge_imports(rest, option.Some(import_), acc)
    [], option.Some(last) -> list.reverse([last, ..acc])
    [], option.None -> list.reverse(acc)
  }
}
