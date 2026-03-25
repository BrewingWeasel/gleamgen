import glance
import gleam/list
import gleam/option.{type Option}
import gleam/order
import gleam/string
import gleamgen/expression.{type Expression}
import gleamgen/function
import gleamgen/types
import gleamgen/types/custom

pub type ImportedModule {
  ImportedModule(
    name: List(String),
    alias: Option(String),
    /// When set, rendered as `import path.{inner}` (no braces in this string).
    exposing: Option(String),
    before_text: String,
    predefined: Bool,
  )
}

pub fn new(name: List(String)) -> ImportedModule {
  ImportedModule(
    name: name,
    alias: option.None,
    exposing: option.None,
    before_text: "",
    predefined: False,
  )
}

pub fn new_with_alias(name: List(String), alias: String) -> ImportedModule {
  ImportedModule(
    name: name,
    alias: option.Some(alias),
    exposing: option.None,
    before_text: "",
    predefined: False,
  )
}

/// Import with a Gleam exposing list, e.g. `new_with_exposing(["a", "b"], "type T, x")`
/// renders `import a/b.{type T, x}`.
pub fn new_with_exposing(name: List(String), exposing: String) -> ImportedModule {
  ImportedModule(
    name: name,
    alias: option.None,
    exposing: option.Some(exposing),
    before_text: "",
    predefined: False,
  )
}

/// Import is always emitted (even if the module reference is not found in rendered bodies).
/// Use for transitive dependencies of embedded expressions (e.g. `cake/select` inside a sub-AST).
pub fn new_predefined(name: List(String)) -> ImportedModule {
  ImportedModule(
    name: name,
    alias: option.None,
    exposing: option.None,
    before_text: "",
    predefined: True,
  )
}

/// Like [`new_predefined`](#new_predefined) but with `as alias` (import always emitted).
pub fn new_predefined_with_alias(name: List(String), alias: String) -> ImportedModule {
  ImportedModule(
    name: name,
    alias: option.Some(alias),
    exposing: option.None,
    before_text: "",
    predefined: True,
  )
}

/// Like [`new_predefined`](#new_predefined) but with `.{exposing}` (import always emitted).
pub fn new_predefined_with_exposing(name: List(String), exposing: String) -> ImportedModule {
  ImportedModule(
    name: name,
    alias: option.None,
    exposing: option.Some(exposing),
    before_text: "",
    predefined: True,
  )
}

pub fn new_with_alias_and_exposing(
  name: List(String),
  alias: String,
  exposing: String,
) -> ImportedModule {
  ImportedModule(
    name: name,
    alias: option.Some(alias),
    exposing: option.Some(exposing),
    before_text: "",
    predefined: False,
  )
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
pub fn function2(
  imported: ImportedModule,
  func: fn(a, b) -> ret,
) -> Expression(fn(a, b) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function3(
  imported: ImportedModule,
  func: fn(a, b, c) -> ret,
) -> Expression(fn(a, b, c) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function4(
  imported: ImportedModule,
  func: fn(a, b, c, d) -> ret,
) -> Expression(fn(a, b, c, d) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function5(
  imported: ImportedModule,
  func: fn(a, b, c, d, e) -> ret,
) -> Expression(fn(a, b, c, d, e) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function6(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f) -> ret,
) -> Expression(fn(a, b, c, d, e, f) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function7(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f, g) -> ret,
) -> Expression(fn(a, b, c, d, e, f, g) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function8(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f, g, h) -> ret,
) -> Expression(fn(a, b, c, d, e, f, g, h) -> ret) {
  let name = function.get_function_name(func)
  expression.raw(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
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
    exposing: option.None,
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

/// Combine exposing clauses when `merge_imports` collapses duplicate module paths.
fn merge_exposing(
  a: Option(String),
  b: Option(String),
) -> Option(String) {
  case a, b {
    option.None, option.None -> option.None
    option.Some(x), option.None -> option.Some(x)
    option.None, option.Some(y) -> option.Some(y)
    option.Some(x), option.Some(y) -> option.Some(x <> ", " <> y)
  }
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
          exposing: merge_exposing(last.exposing, import_.exposing),
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
