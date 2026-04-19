import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/expression/case_
import gleamgen/expression/statement
import gleamgen/function
import gleamgen/import_
import gleamgen/internal/render
import gleamgen/module
import gleamgen/module/definition
import gleamgen/parameter
import gleamgen/pattern
import gleamgen/render/report
import gleamgen/type_
import gleamgen/type_/custom
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub fn simple_todo_test() {
  let result =
    expression.todo_(option.Some("some unimplemented thing"))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "todo as \"some unimplemented thing\""

  assert result == expected
}

pub fn echo_without_as_test() {
  let result =
    expression.echo_(expression.int(3), option.None)
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "echo 3"

  assert result == expected
}

pub fn echo_with_as_test() {
  let result =
    expression.echo_(expression.int(3), option.Some("should be 3"))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "echo 3 as \"should be 3\""

  assert result == expected
}

pub fn simple_assert_test() {
  let condition =
    expression.equals(
      expression.int(2),
      expression.math_operator(
        expression.int(5),
        expression.Sub,
        expression.int(3),
      ),
    )
  let result =
    expression.assert_(condition, option.Some("5 - 3 is 2"))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "assert 2 == 5 - 3 as \"5 - 3 is 2\""

  assert result == expected
}

pub fn block_with_let_matching_test() {
  let result =
    {
      use x <- block.with_let_declaration("x", expression.ok(expression.int(4)))
      use y <- block.with_matching_let_declaration(
        pattern.or(
          pattern.ok(pattern.variable("y")),
          pattern.error(pattern.variable("y")),
        ),
        x,
        False,
      )
      expression.math_operator(y, expression.Add, expression.int(3))
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let x = Ok(4)
  let Ok(y) | Error(y) = x
  y + 3
}"

  assert result == expected
}

pub fn block_dynamic_contents_test() {
  let statements =
    list.range(0, 3)
    |> list.map(fn(index) {
      let #(arguments, callback_arguments) =
        list.range(0, index)
        |> list.map(fn(arg_index) {
          let argument = expression.to_dynamic(expression.int(arg_index))
          #(argument, "_callback" <> int.to_string(arg_index))
        })
        |> list.unzip()
      statement.dynamic_use(
        expression.raw("with_args" <> int.to_string(index)),
        arguments,
        callback_arguments,
      )
    })

  let result =
    {
      use <- block.with_statements(statements)
      expression.nil()
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  use _callback0 <- with_args0(0)
  use _callback0, _callback1 <- with_args1(0, 1)
  use _callback0, _callback1, _callback2 <- with_args2(0, 1, 2)
  use _callback0, _callback1, _callback2, _callback3 <- with_args3(0, 1, 2, 3)
  Nil
}"

  assert result == expected
}

pub fn function_with_labeled_parameters_test() {
  let mod = {
    use _sum_of_2_numbers <- module.with_function(
      definition.new(name: "sum_of_2_numbers")
        |> definition.with_publicity(True),
      function.new2(
        param1: parameter.new("num1", type_.int)
          |> parameter.with_label("first"),
        param2: parameter.new("num2", type_.int)
          |> parameter.with_label("second"),
        returns: type_.int,
        handler: fn(num1, num2) {
          expression.math_operator(num1, expression.Add, num2)
        },
      ),
    )

    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "pub fn sum_of_2_numbers(first num1: Int, second num2: Int) -> Int {
  num1 + num2
}"

  assert result == expected
}

pub fn function_with_auto_inserting_labeled_parameters_test() {
  let mod = {
    use _sum_of_2_numbers <- module.with_function(
      definition.new(name: "sum_of_2_numbers")
        |> definition.with_publicity(True),
      function.new2(
        param1: parameter.new("num1", type_.int)
          |> parameter.with_label("first"),
        param2: parameter.new("num2", type_.int),
        returns: type_.int,
        handler: fn(num1, num2) {
          expression.math_operator(num1, expression.Add, num2)
        },
      ),
    )

    module.eof()
  }

  let rendered = module.render(mod, render.default_context())
  let result = render.to_string(rendered)

  let expected =
    "pub fn sum_of_2_numbers(first num1: Int, num2 num2: Int) -> Int {
  num1 + num2
}"

  assert result == expected
  assert rendered.details.report.warnings
    == [
      report.AutomaticallyAddedMissingLabels(["num2"]),
    ]
}

pub fn module_with_function_test() {
  let mod = {
    use io <- module.with_import(import_.new(["gleam", "io"]))
    use language <- module.with_constant(
      definition.new("language"),
      expression.string("gleam"),
    )

    use describer <- module.with_function(
      definition.new(name: "describer")
        |> definition.with_publicity(True)
        |> definition.with_attributes([definition.Internal]),
      function.new1(
        param1: parameter.new("thing", type_.string),
        returns: type_.string,
        handler: fn(thing) {
          expression.string("The ")
          |> expression.concat_string(thing)
          |> expression.concat_string(expression.string(" is written in "))
          |> expression.concat_string(language)
        },
      ),
    )

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() {
        expression.call1(
          import_.raw_ident(io, "println"),
          expression.call1(describer, expression.string("program")),
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
    "import gleam/io

const language = \"gleam\"

@internal
pub fn describer(thing: String) -> String {
  \"The \" <> thing <> \" is written in \" <> language
}

pub fn main() -> Nil {
  io.println(describer(\"program\"))
}"

  assert result == expected
}

pub fn module_import_constructor_test() {
  let mod = {
    use option_module <- module.with_import(import_.new(["gleam", "option"]))

    let option_type = import_.raw_type(option_module, "Option")

    use _option_from_str <- module.with_function(
      definition.new(name: "option_from_string")
        |> definition.with_publicity(True),
      function.new1(
        param1: parameter.new("str", type_.string),
        returns: option_type |> custom.to_type1(type_.string),
        handler: fn(str) {
          case_.new(str)
          |> case_.with_pattern(pattern.string_literal(""), fn(_) {
            expression.construct0(import_.value_of_type(
              option_module,
              "None",
              type_.function0(option_type |> custom.to_type1(type_.string)),
            ))
          })
          |> case_.with_pattern(pattern.variable("value"), fn(value) {
            expression.construct1(
              import_.value_of_type(
                option_module,
                "Some",
                type_.function1(
                  type_.string,
                  option_type |> custom.to_type1(type_.string),
                ),
              ),
              value,
            )
          })
          |> case_.build_expression()
        },
      ),
    )

    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/option

pub fn option_from_string(str: String) -> option.Option(String) {
  case str {
    \"\" -> option.None
    value -> option.Some(value)
  }
}"

  assert result == expected
}

/// Regression test for list pattern helpers with zero-argument constructors.
///
/// Ensures `pattern.list_empty()` renders as `[]` (not `[]()`), and that a
/// variable pattern matches a non-empty list branch after the empty list arm.
pub fn case_with_list_empty_and_spread_pattern_test() {
  let result =
    case_.new(expression.list([]))
    |> case_.with_pattern(pattern.list_empty(), fn(_) {
      expression.string("empty")
    })
    |> case_.with_pattern(pattern.variable("items"), fn(_) {
      expression.string("not empty")
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case [] {
  [] -> \"empty\"
  items -> \"not empty\"
}"

  assert result == expected
}

/// Regression test for option pattern helper rendering.
///
/// Ensures `pattern.option_some(...)` renders `Some(...)` and
/// `pattern.option_none()` renders `None` (no zero-arg parentheses).
pub fn case_with_option_pattern_helpers_test() {
  let result =
    case_.new(expression.raw("maybe_name"))
    |> case_.with_pattern(
      pattern.option_some(pattern.variable("name")),
      fn(name) { expression.concat_string(name, expression.string("!")) },
    )
    |> case_.with_pattern(pattern.option_none(), fn(_) {
      expression.string("anonymous")
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case maybe_name {
  option.Some(name) -> name <> \"!\"
  option.None -> \"anonymous\"
}"

  assert result == expected
}

pub fn option_helper_without_existing_import_test() {
  let mod = {
    use _ <- module.with_function(
      definition.new(name: "describe_name")
        |> definition.with_publicity(True),
      function.new0(type_.string, fn() {
        case_.new(expression.raw("maybe_name"))
        |> case_.with_pattern(
          pattern.option_some(pattern.variable("name")),
          fn(name) { expression.concat_string(name, expression.string("!")) },
        )
        |> case_.with_pattern(pattern.option_none(), fn(_) {
          expression.string("anonymous")
        })
        |> case_.build_expression()
      }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/option

pub fn describe_name() -> String {
  case maybe_name {
    option.Some(name) -> name <> \"!\"
    option.None -> \"anonymous\"
  }
}"

  assert result == expected
}

pub fn option_helper_combine_with_existing_import_test() {
  let mod = {
    use _option_module <- module.with_import(
      import_.new(["gleam", "option"]) |> import_.with_alias("opt"),
    )

    use _ <- module.with_function(
      definition.new(name: "describe_name")
        |> definition.with_publicity(True),
      function.new0(type_.string, fn() {
        case_.new(expression.raw("maybe_name"))
        |> case_.with_pattern(
          pattern.option_some(pattern.variable("name")),
          fn(name) { expression.concat_string(name, expression.string("!")) },
        )
        |> case_.with_pattern(pattern.option_none(), fn(_) {
          expression.string("anonymous")
        })
        |> case_.build_expression()
      }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/option as opt

pub fn describe_name() -> String {
  case maybe_name {
    opt.Some(name) -> name <> \"!\"
    opt.None -> \"anonymous\"
  }
}"

  assert result == expected
}

pub fn option_helpers_expression_and_type_test() {
  let mod = {
    // use _option_module <- module.with_import(
    //   import_.new(["gleam", "option"]) |> import_.with_alias("opt"),
    // )

    use _ <- module.with_function(
      definition.new(name: "create_optional_name")
        |> definition.with_publicity(True),
      function.new1(
        parameter.new("name", type_.string),
        type_.option(type_.string),
        fn(name) {
          case_.new(name)
          |> case_.with_pattern(pattern.string_literal(""), fn(_) {
            expression.option_none()
          })
          |> case_.with_pattern(
            pattern.variable("existing_name"),
            fn(existing_name) {
              expression.option_some(expression.concat_string(
                existing_name,
                expression.string("!"),
              ))
            },
          )
          |> case_.build_expression()
        },
      ),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/option

pub fn create_optional_name(name: String) -> option.Option(String) {
  case name {
    \"\" -> option.None
    existing_name -> option.Some(existing_name <> \"!\")
  }
}"

  assert result == expected
}

pub fn option_helper_combine_with_unqualified_import_test() {
  let mod = {
    use _option_module <- module.with_import(
      import_.new(["gleam", "option"])
      |> import_.with_exposing([
        import_.ExposedValue("Some", alias: option.None),
        import_.ExposedValue("None", alias: option.None),
      ]),
    )

    use _ <- module.with_function(
      definition.new(name: "describe_name")
        |> definition.with_publicity(True),
      function.new0(type_.string, fn() {
        case_.new(expression.raw("maybe_name"))
        |> case_.with_pattern(
          pattern.option_some(pattern.variable("name")),
          fn(name) { expression.concat_string(name, expression.string("!")) },
        )
        |> case_.with_pattern(pattern.option_none(), fn(_) {
          expression.string("anonymous")
        })
        |> case_.build_expression()
      }),
    )
    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/option.{None, Some}

pub fn describe_name() -> String {
  case maybe_name {
    Some(name) -> name <> \"!\"
    None -> \"anonymous\"
  }
}"

  assert result == expected
}

pub fn result_test() {
  let mod = {
    use result_module <- module.with_import(import_.new(["gleam", "result"]))
    use string_module <- module.with_import(import_.new(["gleam", "string"]))

    use _swap_result <- module.with_function(
      definition.new(name: "handle_result")
        |> definition.with_publicity(True),
      function.new1(
        param1: parameter.new("res", type_.result(type_.string, type_.int)),
        returns: type_.result(type_.bool, type_.int),
        handler: fn(res) {
          use _ <- block.with_let_declaration(
            "v",
            expression.call2(
              import_.value_of_type(
                result_module,
                "unwrap",
                type_.reference(result.unwrap),
              ),
              expression.ok(expression.string("hi")),
              expression.string("hey"),
            ),
          )

          let special_pattern =
            pattern.or(
              pattern.ok(pattern.string_literal("")),
              pattern.error(pattern.int_literal(0)),
            )

          case_.new(res)
          |> case_.with_pattern(special_pattern, fn(_) {
            expression.ok(expression.bool(True))
          })
          |> case_.with_pattern(pattern.ok(pattern.variable("str")), fn(str) {
            expression.call1(
              import_.value_of_type(
                string_module,
                "length",
                type_.reference(string.length),
              ),
              str,
            )
            |> expression.error()
          })
          |> case_.with_pattern(
            pattern.error(pattern.variable("number")),
            fn(number) { expression.error(number) },
          )
          |> case_.build_expression()
        },
      ),
    )

    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "import gleam/result
import gleam/string

pub fn handle_result(res: Result(String, Int)) -> Result(Bool, Int) {
  let v = result.unwrap(Ok(\"hi\"), \"hey\")
  case res {
    Ok(\"\") | Error(0) -> Ok(True)
    Ok(str) -> Error(string.length(str))
    Error(number) -> Error(number)
  }
}"
  assert result == expected
}

pub fn module_with_type_alias_test() {
  let mod = {
    use awesome_string <- module.with_type_alias(
      definition.new(name: "AwesomeString"),
      type_.string,
    )

    use _ <- module.with_function(
      definition.new("runner")
        |> definition.with_publicity(True)
        |> definition.with_attributes([definition.Internal]),
      function.new1(
        param1: parameter.new("thing", awesome_string),
        returns: type_.string,
        handler: fn(thing) {
          expression.string("Hi ")
          |> expression.concat_string(thing)
        },
      ),
    )

    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
    "type AwesomeString = String

@internal
pub fn runner(thing: AwesomeString) -> String {
  \"Hi \" <> thing
}"

  assert result == expected
}
