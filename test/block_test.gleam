import gleam/bool
import gleam/option
import gleam/result
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/expression/statement
import gleamgen/function
import gleamgen/import_
import gleamgen/internal/render
import gleamgen/module
import gleamgen/module/definition
import gleamgen/render/config
import gleamgen/type_

pub fn simple_block_test() {
  let result =
    {
      use x <- block.with_let_declaration("x", expression.int(4))
      use y <- block.with_let_declaration(
        "y",
        expression.math_operator(x, expression.Add, expression.int(5)),
      )
      y
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let x = 4
  let y = x + 5
  y
}"

  assert result == expected
}

pub fn let_declaration_with_type_test() {
  let result =
    {
      use x <- block.with_let_declaration("x", expression.int(4))
      expression.with_render_config(
        {
          use y <- block.with_let_declaration(
            "y",
            expression.math_operator(x, expression.Add, expression.int(5)),
          )
          y
        },
        config.Config(
          ..config.default_config,
          annotate_type_in_let_declarations: True,
        ),
      )
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let x = 4
  let y: Int = x + 5
  y
}"

  assert result == expected
}

pub fn block_with_comment_test() {
  let result =
    {
      use x <- block.with_let_declaration("x", expression.int(4))
      use <- block.with_comments(["should be 9"])
      use y <- block.with_let_declaration(
        "y",
        expression.math_operator(x, expression.Add, expression.int(5)),
      )
      y
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let x = 4
  // should be 9
  let y = x + 5
  y
}"

  assert result == expected
}

pub fn block_with_empty_line_test() {
  let result =
    {
      use x <- block.with_let_declaration("x", expression.int(4))
      use <- block.with_empty_line()
      use <- block.with_comments(["should be 9"])
      use y <- block.with_let_declaration(
        "y",
        expression.math_operator(x, expression.Add, expression.int(5)),
      )
      use <- block.with_empty_line()
      y
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let x = 4

  // should be 9
  let y = x + 5

  y
}"

  assert result == expected
}

pub fn block_with_invalid_multiple_empty_lines_test() {
  let result =
    {
      use x <- block.with_let_declaration("x", expression.int(4))
      use <- block.with_empty_line()
      use <- block.with_empty_line()
      use <- block.with_empty_line()
      use <- block.with_comments(["should be 9"])
      use y <- block.with_let_declaration(
        "y",
        expression.math_operator(x, expression.Add, expression.int(5)),
      )
      use <- block.with_empty_line()
      use <- block.with_empty_line()
      y
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let x = 4

  // should be 9
  let y = x + 5

  y
}"

  assert result == expected
}

pub fn block_with_empty_lines_at_start_and_end_test() {
  let result =
    {
      use <- block.with_empty_line()
      use x <- block.with_let_declaration("x", expression.int(4))
      use <- block.with_empty_line()
      use <- block.with_comments(["should be 9"])
      use y <- block.with_let_declaration(
        "y",
        expression.math_operator(x, expression.Add, expression.int(5)),
      )
      use <- block.with_empty_line()
      y
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let x = 4

  // should be 9
  let y = x + 5

  y
}"

  assert result == expected
}

pub fn block_in_function_test() {
  let block_expr = {
    use x <- block.with_let_declaration("x", expression.int(4))
    use y <- block.with_let_declaration(
      "y",
      expression.math_operator(x, expression.Add, expression.int(5)),
    )
    y
  }

  let result =
    function.new0(type_.int, fn() { block_expr })
    |> function.to_dynamic()
    |> function.render(render.default_context(), option.Some("test_function"))
    |> render.to_string()

  let expected =
    "fn test_function() -> Int {
  let x = 4
  let y = x + 5
  y
}"

  assert result == expected
}

pub fn basic_use_test() {
  let mod = {
    use result_module <- module.with_import(import_.new(["gleam", "result"]))

    use _ <- module.with_function(
      definition.new(name: "do_result")
        |> definition.with_publicity(True),
      function.new0(
        returns: type_.result(type_.int, type_.string),
        handler: fn() {
          use res <- block.with_let_declaration(
            "res",
            expression.ok(expression.int(3)),
          )
          use ok_value <- block.with_use1(
            block.use_function1(
              import_.value_of_type(
                result_module,
                "try",
                type_.reference(result.try),
              ),
              res,
            ),
            "ok_value",
          )

          ok_value
          |> expression.math_operator(expression.Add, expression.int(5))
          |> expression.ok
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

pub fn do_result() -> Result(Int, String) {
  let res = Ok(3)
  use ok_value <- result.try(res)
  Ok(ok_value + 5)
}"
  assert result == expected
}

pub fn two_use_test() {
  let mod = {
    use result_module <- module.with_import(import_.new(["gleam", "result"]))
    use bool_module <- module.with_import(import_.new(["gleam", "bool"]))

    use _ <- module.with_function(
      definition.new(name: "do_result")
        |> definition.with_publicity(True),
      function.new0(
        returns: type_.result(type_.int, type_.string),
        handler: fn() {
          use res <- block.with_let_declaration(
            "res",
            expression.ok(expression.int(3)),
          )

          use ok_value <- block.with_use1(
            block.use_function1(
              import_.value_of_type(
                result_module,
                "try",
                type_.reference(result.try),
              ),
              res,
            ),
            "ok_value",
          )

          use <- block.with_use0(block.use_function2(
            import_.value_of_type(
              bool_module,
              "guard",
              type_.reference(bool.guard),
            ),
            expression.equals(ok_value, expression.int(2)),
            expression.error(expression.string("not equal to 2")),
          ))

          ok_value
          |> expression.math_operator(expression.Add, expression.int(5))
          |> expression.ok
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
    "import gleam/bool
import gleam/result

pub fn do_result() -> Result(Int, String) {
  let res = Ok(3)
  use ok_value <- result.try(res)
  use <- bool.guard(ok_value == 2, Error(\"not equal to 2\"))
  Ok(ok_value + 5)
}"
  assert result == expected
}

/// Regression test for single-expression blocks in `let` values (`render_block`).
///
/// A block value that is only one expression omits redundant `{ ... }`
/// (e.g. `let y = x + 1`, not `let y = { x + 1 }`).
pub fn single_expression_block_in_let_value_test() {
  let value =
    block.new_dynamic([
      statement.expression(expression.math_operator(
        expression.raw("x"),
        expression.Add,
        expression.int(1),
      )),
    ])

  let result =
    block.new_dynamic([
      statement.dynamic_let("y", value, False),
      statement.expression(expression.raw("y")),
    ])
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let y = x + 1
  y
}"

  assert result == expected
}

/// Regression test for rendering block arguments in call expressions.
///
/// Ensures calls like `result.or(...)` keep braces for block arguments with
/// `let` statements, while still unwrapping single-expression blocks (via
/// `render_block`).
pub fn call_with_block_argument_test() {
  let with_let =
    expression.call_dynamic(expression.raw("result.or"), [
      expression.ok(expression.int(3)) |> expression.to_dynamic(),
      block.with_let_declaration("next", expression.int(4), fn(next) {
        expression.ok(next)
      })
        |> expression.to_dynamic(),
    ])
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected_with_let =
    "result.or(Ok(3), {
    let next = 4
    Ok(next)
  })"

  assert with_let == expected_with_let

  let direct_return =
    expression.call_dynamic(expression.raw("result.or"), [
      expression.ok(expression.int(3)) |> expression.to_dynamic(),
      block.new_dynamic([statement.expression(expression.ok(expression.int(4)))]),
    ])
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected_direct_return = "result.or(Ok(3), Ok(4))"

  assert direct_return == expected_direct_return
}
