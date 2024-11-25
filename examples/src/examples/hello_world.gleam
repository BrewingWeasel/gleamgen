import gleam/io
import gleamgen/expression
import gleamgen/function
import gleamgen/import_
import gleamgen/module
import gleamgen/render
import gleamgen/types

pub fn generate() {
  let mod = {
    use io_mod <- module.with_import(import_.new(["gleam", "io"]))

    let io_println = import_.function1(io_mod, io.println)

    use _ <- module.with_function(
      module.DefinitionDetails("main", is_public: True, attributes: []),
      function.new0(types.nil, fn() {
        expression.call1(io_println, expression.string("Hello, world!"))
      }),
    )
    module.eof()
  }
  mod |> module.render(render.default_context()) |> render.to_string()
}
