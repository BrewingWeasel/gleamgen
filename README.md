# Gleamgen

[![Package Version](https://img.shields.io/hexpm/v/gleamgen?color=a6f0fc)](https://hex.pm/packages/gleamgen)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleamgen/)

A package for generating clean, type-checked, and formatted Gleam code!

## Key Features
 - Type safety: ensure generated code is type safe using phantom types
   (including support for functions, custom types, and all builtin operators)
 - Simple escape hatches with the `dynamic` version of functions (generating
   code is by nature dynamic)
 - Automatically fix errors or clean up code. For example gleamgen
   automatically:
    - removes unused imports
    - inlines anonymous functions when appropriate, 
    - simplifies blocks, and combines equivalent case branches
 - Generate code in existing files (combines with existing imports and
   definitions)

## Installation

```sh
gleam add gleamgen
```

## Example

```gleam
import gleam/io
import gleam/list
import gleam/string
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/function
import gleamgen/import_
import gleamgen/module
import gleamgen/module/definition
import gleamgen/parameter
import gleamgen/render
import gleamgen/type_

pub fn generate() {
  let mod = {
    use imported_io <- module.with_import(import_.new(["gleam", "io"]))
    use imported_string <- module.with_import(import_.new(["gleam", "string"]))

    // module_used is of type Expression(String)
    use module_used <- module.with_constant(
      definition.new("module_used"),
      expression.string("Gleamgen"),
    )

    use greeter <- module.with_function(
      definition.new("greeter"),
      function.new1(
        param1: parameter.new("greeting", type_.string),
        // we have said that greeter returns a string, so handler returning anything
        // else would be a type error
        returns: type_.string,
        handler: fn(greeting) {
          greeting
          |> expression.concat_string(expression.string(" from "))
          // trying to concatenate any other type would be a compilation error
          |> expression.concat_string(module_used)
        },
      ),
    )

    // Let's pick a greeting that we will use inside the generated code
    let assert [outer_greeting, ..] =
      list.shuffle([
        expression.string("Howdy"),
        expression.string("Hello"),
        expression.call2(
          // If this is not the selected greeting, gleam/string will not be
          // imported in the final code
          import_.value_of_type(
            imported_string,
            "repeat",
            type_.reference(string.repeat),
          ),
          expression.string("Hi"),
          expression.int(5),
        ),
      ])

    use _main <- module.with_function(
      definition.new("main") |> definition.with_publicity(True),
      function.new0(type_.nil, fn() {
        use greeting <- block.with_let_declaration(
          "greeting",
          expression.call1(greeter, outer_greeting),
        )
        expression.call1(
          // reference the actual io.println function to get the name and
          // the type signature
          import_.value_of_type(
            imported_io,
            "println",
            type_.reference(io.println),
          ),
          greeting,
        )
      }),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
}
```

This will generate something like:

```gleam
import gleam/io

const module_used = "Gleamgen"

fn greeter(greeting: String) -> String {
  greeting <> " from " <> module_used
}

pub fn main() -> Nil {
  let greeting = greeter("Hello")
  io.println(greeting)
}
```

To get started, check out the [getting started
guide](https://hexdocs.pm/gleamgen/getting_started.html), [the
docs](https://hexdocs.pm/gleamgen/), and the examples folder.
