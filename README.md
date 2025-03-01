# Gleamgen

[![Package Version](https://img.shields.io/hexpm/v/gleamgen?color=a6f0fc)](https://hex.pm/packages/gleamgen)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gleamgen/)

A package for generating clean, type-checked, and formatted Gleam code ✏️

## Installation 🚀

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
import gleamgen/render
import gleamgen/types

pub fn main() {
  let mod = {
    use imported_io <- module.with_import(import_.new(["gleam", "io"]))
    use imported_string <- module.with_import(import_.new(["gleam", "string"]))

    // module_used is of type Expression(String)
    use module_used <- module.with_constant(
      module.DefinitionDetails(
        name: "module_used",
        is_public: False,
        attributes: [],
      ),
      expression.string("Gleamgen"),
    )

    use greeter <- module.with_function(
      module.DefinitionDetails(
        name: "greeter",
        is_public: False,
        attributes: [],
      ),
      function.new1(
        arg1: #("greeting", types.string),
        // we have said that greeter returns a string, so handler returning anything
        // else would be a type error
        returns: types.string,
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
          import_.function2(imported_string, string.repeat),
          expression.string("Hi"),
          expression.int(5),
        ),
      ])

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(types.nil, fn() {
        {
          use greeting <- block.with_let_declaration(
            "greeting",
            expression.call1(greeter, outer_greeting),
          )
          block.ending_block(expression.call1(
            // reference the actual io.println function to get the name and
            // the type signature
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

const module_used = "Gleamgen"

fn greeter(greeting: String) -> String {
  greeting <> " from " <> module_used
}

pub fn main() -> Nil {
  let greeting = greeter("Hello")
  io.println(greeting)
}
```

In general, there are two versions of every gleamgen function:

- The version with phantom types to ensure type safety of the generated code
- The untyped version (generally with the suffix `_unchecked`)

When possible, use the typed version to ensure the correctness of the generated code.

However, in cases where you are dynamically generating the arguments or the
types of functions, you will have to use the unchecked versions.

You can easily integrate between the two with functions such as
`expression.to_unchecked` or `expression.unsafe_from_unchecked`

Further documentation can be found at <https://hexdocs.pm/gleamgen>.
Also check out the examples folder (or the tests).

Note: There are still a lot of basic functions that have yet to be implemented, and
the way things like generics are handled are subject to change
