import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/string
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/expression/statement
import gleamgen/function
import gleamgen/import_
import gleamgen/module
import gleamgen/module/definition
import gleamgen/render
import gleamgen/source
import gleamgen/types

const sample_module = "import gleam/int
import gleam/io

/// Prints an integer
pub fn println_int(int: Int) {
  io.println(int.to_string(int))
}
"

pub fn extend_module_from_string_test() {
  let assert Ok(source_map) = source.module_from_string(sample_module)
  let mod = {
    let mod = module.from_source_map(source_map)

    use _ <- module.with_function(
      definition.new("main")
        |> definition.with_publicity(True),
      function.new0(types.nil, fn() {
        expression.call1(expression.raw("println_int"), expression.int(46))
      }),
    )

    mod
  }

  let result =
    mod |> module.render(render.default_context()) |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io

/// Prints an integer
pub fn println_int(int: Int) {
  io.println(int.to_string(int))
}

pub fn main() -> Nil {
  println_int(46)
}"

  assert result == expected
}

pub fn extend_module_other_imports_test() {
  let assert Ok(source_map) = source.module_from_string(sample_module)
  let mod = {
    let mod = module.from_source_map(source_map)
    use string_mod <- module.with_import(import_.new(["gleam", "string"]))
    use io_mod <- module.with_import(import_.new(["gleam", "io"]))

    let io_println =
      import_.value_of_type(io_mod, "println", types.reference(io.println))

    let string_repeat =
      import_.value_of_type(
        string_mod,
        "repeat",
        types.reference(string.repeat),
      )

    use _ <- module.with_function(
      definition.new("main")
        |> definition.with_publicity(True),
      function.new0(types.nil, fn() {
        expression.call1(
          io_println,
          expression.call2(
            string_repeat,
            expression.string("hi"),
            expression.int(3),
          ),
        )
      }),
    )

    mod
  }

  let result =
    mod |> module.render(render.default_context()) |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io
import gleam/string

/// Prints an integer
pub fn println_int(int: Int) {
  io.println(int.to_string(int))
}

pub fn main() -> Nil {
  io.println(string.repeat(\"hi\", 3))
}"

  assert result == expected
}

pub fn module_definition_placement_test() {
  let assert Ok(source_map) = source.module_from_string(sample_module)
  let mod = {
    let mod = module.from_source_map(source_map)

    use _ <- module.with_function(
      definition.new("main")
        |> definition.with_publicity(True)
        |> definition.with_position(definition.Top),
      function.new0(types.nil, fn() {
        expression.call1(expression.raw("println_int"), expression.int(46))
      }),
    )

    mod
  }

  let result =
    mod |> module.render(render.default_context()) |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io

pub fn main() -> Nil {
  println_int(46)
}

/// Prints an integer
pub fn println_int(int: Int) {
  io.println(int.to_string(int))
}"

  assert result == expected
}

pub fn module_replace_function_test() {
  let assert Ok(source_map) = source.module_from_string(sample_module)
  let mod = {
    let mod = module.from_source_map(source_map)
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use io_mod <- module.with_import(import_.new(["gleam", "io"]))

    let io_print =
      import_.value_of_type(io_mod, "print", types.reference(io.print))

    let int_to_string =
      import_.value_of_type(
        int_mod,
        "to_string",
        types.reference(int.to_string),
      )

    use mod, _println_int <- module.replace_function(
      "println_int",
      mod,
      fn(_original_function) {
        function.new1(#("int", types.int), types.nil, fn(arg) {
          expression.call1(io_print, expression.call1(int_to_string, arg))
        })
      },
      module.ReplacementInline,
    )

    mod
  }

  let result =
    mod |> module.render(render.default_context()) |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io

/// Prints an integer
pub fn println_int(int: Int) -> Nil {
  io.print(int.to_string(int))
}"

  assert result == expected
}

pub fn module_replace_function_make_private_test() {
  let assert Ok(source_map) = source.module_from_string(sample_module)
  let mod = {
    let mod = module.from_source_map(source_map)
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use io_mod <- module.with_import(import_.new(["gleam", "io"]))

    let io_print =
      import_.value_of_type(io_mod, "print", types.reference(io.print))

    let int_to_string =
      import_.value_of_type(
        int_mod,
        "to_string",
        types.reference(int.to_string),
      )

    let replacement_method =
      module.ReplacementUpdateDefinition(fn(definition) {
        definition.with_publicity(definition, False)
      })

    use mod, _println_int <- module.replace_function(
      "println_int",
      mod,
      fn(_original_function) {
        function.new1(#("int", types.int), types.nil, fn(arg) {
          expression.call1(io_print, expression.call1(int_to_string, arg))
        })
      },
      replacement_method,
    )

    mod
  }

  let result =
    mod |> module.render(render.default_context()) |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io

/// Prints an integer
fn println_int(int: Int) -> Nil {
  io.print(int.to_string(int))
}"

  assert result == expected
}

const sample_module_with_many_statements = "import gleam/bool

/// A function with many statements
pub fn statements() -> Nil {
  // Comment here
  use <- bool.guard(False, Nil)
  // And here
  use <- bool.guard(False, Nil)
  use <- bool.guard(False, Nil)

  assert 5 > 2

  Nil
}"

pub fn replace_function_update_statements_test() {
  let assert Ok(source_map) =
    source.module_from_string(sample_module_with_many_statements)
  let mod = {
    let mod = module.from_source_map(source_map)
    use mod, _println_int <- module.replace_function(
      "statements",
      mod,
      fn(original_function) {
        let assert option.Some(function) = original_function
        function.new0(types.nil, fn() {
          source.get_function_body(function)
          |> list.map(statement.from_source_map)
          |> block.new_dynamic()
        })
      },
      module.ReplacementInline,
    )

    mod
  }

  let result =
    mod |> module.render(render.default_context()) |> render.to_string()

  assert result == sample_module_with_many_statements
}
