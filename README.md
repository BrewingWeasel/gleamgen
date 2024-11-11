# Gleamgen

[![Package Version](https://img.shields.io/hexpm/v/gleamgen?color=a6f0fc)](https://hex.pm/packages/gleamgen)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleamgen/)

A clean, type-safe\* package for generating formatted Gleam code

## Installation

```sh
gleam add gleamgen
```

## Example

```gleam
import gleam/io
import gleam/list
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/function
import gleamgen/import_
import gleamgen/module
import gleamgen/render
import gleamgen/types

pub fn main() {
  let mod = {
    use imported_io <- module.with_import(import_.new(["gleam", "io"]))

    // module_used is of the type Expression(String)
    use module_used <- module.with_constant(
      "module_used",
      expression.string("Gleamgen"),
    )

    use greeter <- module.with_function(
      "greeter",
      function.new1(
        arg1: #("greeting", types.string()),
        // we have said that greeter returns a string, so handler returning
        // anything else would be a type error
        returns: types.string(),
        handler: fn(greeting) {
          greeting
          |> expression.concat_string(expression.string(" from "))
          // trying to concatenate any other type would be a compilation error
          |> expression.concat_string(module_used)
        },
      ),
    )

    // Let's pick a greeting that we will use inside the generated code
    let assert [outer_greeting, ..] = list.shuffle(["Howdy", "Hello", "Hi"])

    use _main <- module.with_function(
      "main",
      function.new0(types.nil(), fn() {
        {
          use greeting <- block.with_let_declaration(
            "greeting",
            expression.call1(greeter, expression.string(outer_greeting)),
          )
          block.ending_block(expression.call1(
            // reference the actual io.println function to get the name
            // and the type signature
            import_.function1(imported_io, io.println),
            greeting,
          ))
        }
        |> block.build()
      }),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> io.println()
}
```

This will generate something like:

```gleam
import gleam/io

pub const module_used = "Gleamgen"

pub fn greeter(greeting: String) -> String {
  greeting <> " from " <> module_used
}

pub fn main() -> Nil {
  let greeting = greeter("Hello")
  io.println(greeting)
}
```

Further documentation can be found at <https://hexdocs.pm/gleamgen>.
