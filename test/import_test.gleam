import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/string
import gleamgen/expression
import gleamgen/function
import gleamgen/import_
import gleamgen/internal/render
import gleamgen/module
import gleamgen/module/definition
import gleamgen/parameter
import gleamgen/type_

pub fn module_import_test() {
  let mod = {
    use io <- module.with_import(
      import_.new(["gleam", "io"]) |> import_.with_alias("only_o"),
    )
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))

    let io_print =
      import_.value_of_type(io, "println", type_.reference(io.println))
    let int_string =
      import_.value_of_type(
        int_mod,
        "to_string",
        type_.reference(int.to_string),
      )

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() {
        expression.call1(
          io_print,
          expression.call1(int_string, expression.int(23)),
        )
      }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io as only_o

pub fn main() -> Nil {
  only_o.println(int.to_string(23))
}"

  assert result == expected
}

pub fn module_import_unqualified_test() {
  let mod = {
    use io <- module.with_import(
      import_.new(["gleam", "io"])
      |> import_.with_alias("only_o")
      |> import_.with_unqualified_items([
        import_.UnqualifiedValue("println", option.None),
      ]),
    )
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))

    let io_print =
      import_.value_of_type(io, "println", type_.reference(io.println))
    let int_string =
      import_.value_of_type(
        int_mod,
        "to_string",
        type_.reference(int.to_string),
      )

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() {
        expression.call1(
          io_print,
          expression.call1(int_string, expression.int(23)),
        )
      }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io.{println} as only_o

pub fn main() -> Nil {
  println(int.to_string(23))
}"

  assert result == expected
}

/// Regression test for `import_.with_exposing`: rendered `import path.{items}` and kept in output
/// when nothing references the module prefix (only unqualified imports from the exposing list).
pub fn module_import_with_exposing_test() {
  let mod = {
    use _string <- module.with_import(
      import_.new(["gleam", "string"])
      |> import_.with_unqualified_items([import_.unqualified_value("length")]),
    )

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() { expression.nil() }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/string.{length}

pub fn main() -> Nil {
  Nil
}"

  assert result == expected
}

/// `import path.{items} as alias` — exposing must come before `as` in Gleam syntax.
pub fn module_import_with_alias_and_exposing_test() {
  let mod = {
    use io <- module.with_import(
      import_.new(["gleam", "io"])
      |> import_.with_unqualified_items([import_.unqualified_value("print")])
      |> import_.with_alias("only_o"),
    )

    let io_print =
      import_.value_of_type(io, "println", type_.reference(io.println))

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() {
        expression.call1(io_print, expression.string("hi"))
      }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/io.{print} as only_o

pub fn main() -> Nil {
  only_o.println(\"hi\")
}"

  assert result == expected
}

/// Duplicate module paths with separate exposing lists merge into one import (sorted, deduped).
pub fn module_merge_imports_exposing_test() {
  let mod = {
    use _ <- module.with_import(
      import_.new(["gleam", "string"])
      |> import_.with_unqualified_items([import_.unqualified_value("reverse")]),
    )
    use _ <- module.with_import(
      import_.new(["gleam", "string"])
      |> import_.with_unqualified_items([import_.unqualified_value("length")]),
    )

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() { expression.nil() }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/string.{length, reverse}

pub fn main() -> Nil {
  Nil
}"

  assert result == expected
}

/// Merging imports with overlapping exposing lists deduplicates entries.
pub fn module_merge_imports_exposing_dedupes_test() {
  let mod = {
    use _ <- module.with_import(
      import_.new(["gleam", "string"])
      |> import_.with_unqualified_items([import_.unqualified_value("length")]),
    )
    use _ <- module.with_import(
      import_.new(["gleam", "string"])
      |> import_.with_unqualified_items([import_.unqualified_value("length")]),
    )

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() { expression.nil() }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/string.{length}

pub fn main() -> Nil {
  Nil
}"

  assert result == expected
}

pub fn module_unused_import_test() {
  let mod = {
    use io <- module.with_import(
      import_.new(["gleam", "io"]) |> import_.with_alias("only_o"),
    )
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use _ <- module.with_import(import_.new(["gleam", "string"]))

    let io_print =
      import_.value_of_type(io, "println", type_.reference(io.println))
    let int_string =
      import_.value_of_type(
        int_mod,
        "to_string",
        type_.reference(int.to_string),
      )

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() {
        expression.call1(
          io_print,
          expression.call1(int_string, expression.int(23)),
        )
      }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io as only_o

pub fn main() -> Nil {
  only_o.println(int.to_string(23))
}"

  assert result == expected
}

// Because this is False, we don't use the string module, 
// therefore it should not be rendered in the final string
const use_string_mod_this_time = False

pub fn module_sometimes_unused_import_test() {
  let mod = {
    use io <- module.with_import(
      import_.new(["gleam", "io"]) |> import_.with_alias("only_o"),
    )
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use string_mod <- module.with_import(import_.new(["gleam", "string"]))

    let io_print =
      import_.value_of_type(io, "println", type_.reference(io.println))
    let int_string =
      import_.value_of_type(
        int_mod,
        "to_string",
        type_.reference(int.to_string),
      )
    let string_length =
      import_.value_of_type(
        string_mod,
        "length",
        type_.reference(string.length),
      )

    let int_value = case use_string_mod_this_time {
      True -> expression.call1(string_length, expression.string("hi"))
      False -> expression.int(23)
    }

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() {
        expression.call1(io_print, expression.call1(int_string, int_value))
      }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/int
import gleam/io as only_o

pub fn main() -> Nil {
  only_o.println(int.to_string(23))
}"

  assert result == expected
}

pub fn sort_like_module_emits_one_structure_import_test() {
  let mod = {
    use structure <- module.with_import(import_.new(["cat_db", "structure"]))
    let field_t = type_.custom_type(Some(structure), "CatField", [])
    let func =
      function.new1(parameter.new("field", field_t), type_.string, fn(_f) {
        expression.string("x")
      })
    let details =
      definition.new("cat_field_sql")
      |> definition.with_publicity(True)

    use _ <- module.with_function(details, func)
    module.eof()
  }
  let s =
    module.render(mod, render.default_context())
    |> render.to_string()
  let parts = string.split(s, "import cat_db/structure")
  assert list.length(parts) == 2
}
