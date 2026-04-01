import gleam/list
import gleam/string

import gleam/option.{Some}

import gleamgen/expression
import gleamgen/function
import gleamgen/import_
import gleamgen/module
import gleamgen/module/definition
import gleamgen/parameter
import gleamgen/render
import gleamgen/types

pub fn sort_like_module_emits_one_structure_import_test() {
  let sm = import_.new(["cat_db", "structure"])
  let field_t = types.custom_type(Some("structure"), "CatField", [])
  let func =
    function.new1(parameter.new("field", field_t), types.string, fn(_f) {
      expression.string("x")
    })
  let details =
    definition.new("cat_field_sql")
    |> definition.with_publicity(True)
  let mod =
    module.with_import(sm, fn(_) {
      module.with_function(details, func, fn(_) { module.eof() })
    })
  let s =
    module.render(mod, render.default_context())
    |> render.to_string()
  let parts = string.split(s, "import cat_db/structure")
  assert list.length(parts) == 2
}

pub fn function_only_module_does_not_emit_import_lines_test() {
  let field_t = types.custom_type(Some("structure"), "CatField", [])
  let func =
    function.new1(parameter.new("field", field_t), types.string, fn(_f) {
      expression.string("x")
    })
  let details =
    definition.new("cat_field_sql")
    |> definition.with_publicity(True)
  let mod = module.with_function(details, func, fn(_) { module.eof() })
  let s =
    module.render(mod, render.default_context())
    |> render.to_string()
  assert string.contains(s, "import ") == False
}
