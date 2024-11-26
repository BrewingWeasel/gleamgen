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

pub fn generate() {
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
}
