import gleam/list
import gleam/option.{type Option}
import gleamgen/expression.{type Expression}
import gleamgen/function
import gleamgen/types
import gleamgen/types/custom

pub type ImportedModule {
  ImportedModule(name: List(String), alias: Option(String))
}

pub fn new(name: List(String)) -> ImportedModule {
  ImportedModule(name: name, alias: option.None)
}

pub fn new_with_alias(name: List(String), alias: String) -> ImportedModule {
  ImportedModule(name: name, alias: option.Some(alias))
}

fn get_reference(imported: ImportedModule) -> String {
  case imported.alias {
    option.Some(alias) -> alias
    option.None -> {
      let assert Ok(name) = imported.name |> list.last
      name
    }
  }
}

pub fn unchecked_ident(
  imported: ImportedModule,
  name: String,
) -> Expression(any) {
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}

pub fn value_of_type(
  imported: ImportedModule,
  name: String,
  type_: types.GeneratedType(t),
) -> Expression(t) {
  expression.unchecked_of_type(get_reference(imported) <> "." <> name, type_)
}

pub fn unchecked_type(
  imported: ImportedModule,
  name: String,
) -> custom.CustomType(t, generics) {
  custom.CustomType(get_reference(imported) <> "." <> name)
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
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
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
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
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
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function3(
  imported: ImportedModule,
  func: fn(a, b, c) -> ret,
) -> Expression(fn(a, b, c) -> ret) {
  let name = function.get_function_name(func)
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function4(
  imported: ImportedModule,
  func: fn(a, b, c, d) -> ret,
) -> Expression(fn(a, b, c, d) -> ret) {
  let name = function.get_function_name(func)
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function5(
  imported: ImportedModule,
  func: fn(a, b, c, d, e) -> ret,
) -> Expression(fn(a, b, c, d, e) -> ret) {
  let name = function.get_function_name(func)
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function6(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f) -> ret,
) -> Expression(fn(a, b, c, d, e, f) -> ret) {
  let name = function.get_function_name(func)
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function7(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f, g) -> ret,
) -> Expression(fn(a, b, c, d, e, f, g) -> ret) {
  let name = function.get_function_name(func)
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function8(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f, g, h) -> ret,
) -> Expression(fn(a, b, c, d, e, f, g, h) -> ret) {
  let name = function.get_function_name(func)
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}

/// Import an existing function from the module.
/// See `function1` for more details.
pub fn function9(
  imported: ImportedModule,
  func: fn(a, b, c, d, e, f, g, h, i) -> ret,
) -> Expression(fn(a, b, c, d, e, f, g, h, i) -> ret) {
  let name = function.get_function_name(func)
  expression.unchecked_ident(get_reference(imported) <> "." <> name)
}
// }}}
// vim: foldmethod=marker foldlevel=0
