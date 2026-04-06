import gleam/list
import gleam/string
import gleamgen/expression
import gleamgen/function
import gleamgen/import_
import gleamgen/module
import gleamgen/module/definition
import gleamgen/render
import gleamgen/types
import simplifile

pub fn generate() -> String {
  let assert Ok(files) = simplifile.read_directory("src/examples")
  let file_roots = files |> list.map(string.replace(_, ".gleam", ""))

  let mod = {
    use imports <- module.with_dynamic_imports(
      file_roots
      |> list.map(fn(file) { import_.new(["examples", file]) }),
    )
    use _ <- module.with_function(
      definition.new("get_all_examples") |> definition.with_publicity(True),
      function.new0(
        types.list(types.tuple2(types.function0(types.string), types.string)),
        fn() {
          imports
          |> list.zip(file_roots)
          |> list.map(fn(current_import) {
            let #(imported_example, file_name) = current_import
            expression.tuple2(
              import_.value_of_type(
                imported_example,
                "generate",
                types.reference(generate),
              ),
              expression.string(file_name),
            )
          })
          |> expression.list()
        },
      ),
    )
    module.eof()
  }
  mod |> module.render(render.default_context()) |> render.to_string()
}
