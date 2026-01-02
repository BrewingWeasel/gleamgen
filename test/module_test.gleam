import gleam/int
import gleam/io
import gleam/string
import gleamgen/expression
import gleamgen/function
import gleamgen/import_
import gleamgen/module
import gleamgen/module/definition
import gleamgen/render
import gleamgen/types

const sample_module = "import gleam/int
import gleam/io

/// Prints an integer
pub fn println_int(int: Int) {
  io.println(int.to_string(int))
}
"

pub fn extend_module_from_string_test() {
  let mod = {
    let mod = module.from_string(sample_module)

    use _ <- module.with_function(
      definition.new("main")
        |> definition.with_publicity(True),
      function.new0(types.nil, fn() {
        expression.call1(
          expression.raw("println_int"),
          expression.int(46),
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
  let mod = {
    let mod = module.from_string(sample_module)
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
  let mod = {
    let mod = module.from_string(sample_module)

    use _ <- module.with_function(
      definition.new("main")
        |> definition.with_publicity(True)
        |> definition.with_position(definition.Top),
      function.new0(types.nil, fn() {
        expression.call1(
          expression.raw("println_int"),
          expression.int(46),
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
  let mod = {
    let mod = module.from_string(sample_module)
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
