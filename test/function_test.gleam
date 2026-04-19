import gleamgen/expression
import gleamgen/expression/block
import gleamgen/function
import gleamgen/internal/render
import gleamgen/module
import gleamgen/module/definition
import gleamgen/parameter
import gleamgen/render/config
import gleamgen/render/report
import gleamgen/type_

pub fn anonymous_functions_ignore_labels_test() {
  let add_function =
    function.new2(
      param1: parameter.new("num1", type_.int)
        |> parameter.with_label("first"),
      param2: parameter.new("num2", type_.int)
        |> parameter.with_label("second"),
      returns: type_.int,
      handler: fn(num1, num2) {
        expression.math_operator(num1, expression.Add, num2)
      },
    )
  let mod = {
    use _sum_of_2_numbers <- module.with_function(
      definition.new(name: "sum_of_2_numbers")
        |> definition.with_publicity(True),
      add_function,
    )

    use _sum_of_2_and_3 <- module.with_function(
      definition.new(name: "sum_of_2_and_3")
        |> definition.with_publicity(True),
      function.new0(type_.int, fn() {
        use add_function_expr <- block.with_let_declaration(
          "add_function",
          function.anonymous(add_function),
        )
        expression.call2(
          add_function_expr,
          expression.int(2),
          expression.int(3),
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
    "pub fn sum_of_2_numbers(first num1: Int, second num2: Int) -> Int {
  num1 + num2
}

pub fn sum_of_2_and_3() -> Int {
  let add_function = fn(num1: Int, num2: Int) -> Int { num1 + num2 }
  add_function(2, 3)
}"

  assert result == expected
}

pub fn function_notice_unlabeled_parameters_test() {
  let mod = {
    use _list_of_6_numbers <- module.with_function(
      definition.new(name: "list_of_6_numbers")
        |> definition.with_publicity(True),
      function.new6(
        param1: parameter.new("num1", type_.int),
        param2: parameter.new("num2", type_.int)
          |> parameter.with_label("second"),
        param3: parameter.new("num3", type_.int),
        param4: parameter.new("num4", type_.int),
        param5: parameter.new("num5", type_.int)
          |> parameter.with_label("fifth"),
        param6: parameter.new("num6", type_.int),
        returns: type_.list(type_.int),
        handler: fn(num1, num2, num3, num4, num5, num6) {
          expression.list([
            num1,
            num2,
            num3,
            num4,
            num5,
            num6,
          ])
        },
      ),
    )

    module.eof()
  }

  let config =
    render.context_from_config(
      config.Config(..config.default_config, auto_fix_parameters: False),
    )

  let rendered = module.render(mod, config)
  let result = render.to_string(rendered)

  let expected =
    "pub fn list_of_6_numbers(
  num1: Int,
  second num2: Int,
  num3: Int,
  num4: Int,
  fifth num5: Int,
  num6: Int,
) -> List(Int) {
  [num1, num2, num3, num4, num5, num6]
}"

  assert result == expected
  assert rendered.details.report.errors
    == [
      report.MissingLabels(["num3", "num4", "num6"]),
    ]
}

pub fn simple_anonymous_function_test() {
  let result =
    {
      use func <- block.with_let_declaration(
        "func",
        function.anonymous(
          function.new2(
            parameter.new("x", type_.int),
            parameter.new("y", type_.int),
            type_.int,
            handler: fn(x, y) { expression.math_operator(x, expression.Add, y) },
          ),
        ),
      )
      expression.call2(func, expression.int(2), expression.int(3))
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "{
  let func = fn(x: Int, y: Int) -> Int { x + y }
  func(2, 3)
}"

  assert result == expected
}

pub fn inline_simple_anonymous_function_test() {
  let result =
    {
      let anonymous_function =
        function.anonymous(
          function.new2(
            parameter.new("x", type_.int),
            parameter.new("y", type_.int),
            type_.int,
            handler: fn(x, y) { expression.math_operator(x, expression.Add, y) },
          ),
        )
      expression.call2(anonymous_function, expression.int(2), expression.int(3))
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "2 + 3"

  assert result == expected
}

pub fn inline_zero_argument_function_test() {
  let result =
    {
      let anonymous_function =
        function.anonymous(
          function.new0(type_.int, handler: fn() {
            expression.math_operator(
              expression.int(5),
              expression.Add,
              expression.int(3),
            )
          }),
        )
      expression.call0(anonymous_function)
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "5 + 3"

  assert result == expected
}

pub fn do_not_inline_unclear_functions_test() {
  let result =
    {
      let anonymous_function =
        function.anonymous(
          function.new1(
            type_.int,
            param1: parameter.new("_example", type_.int),
            handler: fn(_example) {
              expression.raw("echo \"who knows what's going on in here\"")
            },
          ),
        )
      expression.call1(anonymous_function, expression.int(0))
    }
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "fn(_example: Int) -> Int { echo \"who knows what's going on in here\" }(0)"

  assert result == expected
}
