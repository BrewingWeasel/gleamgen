import gleam/io
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
    use io_mod <- module.with_import(import_.new(["gleam", "io"]))
    use greeting <- module.with_constant(
      definition.new("greeting") |> definition.with_publicity(True),
      expression.string("hello"),
    )

    use greet_user <- module.with_function(
      definition.new("greet_user"),
      function.new1(
        param1: parameter.new("user", type_.string),
        returns: type_.string,
        handler: fn(user) {
          expression.concat_string(
            expression.concat_string(greeting, expression.string(" ")),
            user,
          )
        },
      ),
    )

    let io_println =
      import_.value_of_type(io_mod, "println", type_.reference(io.println))

    let main_function = fn() {
      use name <- block.with_let_declaration(
        "name",
        expression.string("Viktor"),
      )
      use <- block.with_comments(["A greeting for the given name"])
      use greeting <- block.with_let_declaration(
        "greeting",
        expression.call1(greet_user, name),
      )
      use <- block.with_empty_line()
      expression.call1(io_println, greeting)
    }

    use _main <- module.with_function(
      definition.new("main") |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: main_function),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
}
