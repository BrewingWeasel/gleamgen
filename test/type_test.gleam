import gleam/option
import gleamgen/expression
import gleamgen/function
import gleamgen/import_
import gleamgen/internal/render
import gleamgen/module
import gleamgen/module/definition
import gleamgen/type_

pub fn module_with_generic_type_emits_imports_for_type_args_test() {
  let mod = {
    use mist_module <- module.with_import(import_.new(["mist"]))
    use response_module <- module.with_import(
      import_.new(["gleam", "http", "response"]),
    )

    let mist_data =
      type_.custom_type(option.Some(mist_module), "ResponseData", [])
    let return_type =
      type_.custom_type(option.Some(response_module), "Response", [
        mist_data |> type_.to_dynamic(),
      ])

    use _handler <- module.with_function(
      definition.new("handler") |> definition.with_publicity(True),
      function.new0(returns: return_type, handler: fn() {
        expression.todo_(option.None)
      }),
    )
    module.eof()
  }

  let result =
    mod |> module.render(render.default_context()) |> render.to_string()

  let expected =
    "import gleam/http/response
import mist

pub fn handler() -> response.Response(mist.ResponseData) {
  todo
}"

  assert result == expected
}
