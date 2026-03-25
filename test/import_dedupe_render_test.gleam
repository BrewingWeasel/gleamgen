import gleam/list
import gleam/string

import gleam/option.{Some}

import gleamgen/expression as gex
import gleamgen/function as gfun
import gleamgen/import_ as gim
import gleamgen/module as gmod
import gleamgen/module/definition as gdef
import gleamgen/parameter as gparam
import gleamgen/render as grender
import gleamgen/types as gtypes

pub fn sort_like_module_emits_one_structure_import_test() {
  let sm = gim.new(["cat_db", "structure"])
  let field_t = gtypes.custom_type(Some("structure"), "CatField", [])
  let func =
    gfun.new1(
      gparam.new("field", field_t),
      gtypes.string,
      fn(_f) { gex.string("x") },
    )
  let details =
    gdef.new("cat_field_sql")
    |> gdef.with_publicity(True)
  let mod =
    gmod.with_import(sm, fn(_) {
      gmod.with_function(details, func, fn(_) { gmod.eof() })
    })
  let s =
    gmod.render(mod, grender.default_context())
    |> grender.to_string()
  let parts = string.split(s, "import cat_db/structure")
  let assert True = list.length(parts) == 2
}

pub fn function_only_module_does_not_emit_import_lines_test() {
  let field_t = gtypes.custom_type(Some("structure"), "CatField", [])
  let func =
    gfun.new1(
      gparam.new("field", field_t),
      gtypes.string,
      fn(_f) { gex.string("x") },
    )
  let details =
    gdef.new("cat_field_sql")
    |> gdef.with_publicity(True)
  let mod =
    gmod.with_function(details, func, fn(_) { gmod.eof() })
  let s =
    gmod.render(mod, grender.default_context())
    |> grender.to_string()
  let assert False = string.contains(s, "import ")
}
