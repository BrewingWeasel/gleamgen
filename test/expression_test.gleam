import gleamgen/expression
import gleamgen/internal/render

pub fn simple_int_addition_test() {
  let result =
    expression.int(3)
    |> expression.math_operator(expression.Add, expression.int(5))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "3 + 5"

  assert result == expected
}

pub fn simple_string_test() {
  let result =
    expression.string("hello")
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "\"hello\""

  assert result == expected
}

pub fn string_escape_quote_test() {
  let result =
    expression.string("hel\"lo")
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "\"hel\\\"lo\""

  assert result == expected
}

pub fn string_newline_test() {
  let result =
    expression.string("hel\nlo")
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "\"hel
lo\""

  assert result == expected
}

pub fn string_escape_slash_test() {
  let result =
    expression.string("hello\\hi")
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "\"hello\\\\hi\""

  assert result == expected as "the generated slash should also be escaped"
}

pub fn empty_string_test() {
  let result =
    expression.string("")
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "\"\""

  assert result == expected
}

pub fn simple_or_test() {
  let result =
    expression.int(3)
    |> expression.equals(expression.int(4))
    |> expression.or(expression.bool(True))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "3 == 4 || True"

  assert result == expected
}

pub fn simple_and_test() {
  let result =
    expression.int(3)
    |> expression.equals(expression.int(4))
    |> expression.and(expression.bool(False))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "3 == 4 && False"

  assert result == expected
}

pub fn simple_tuple_test() {
  let result =
    expression.tuple3(
      expression.int(3),
      expression.string("hello"),
      expression.bool(True),
    )
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "#(3, \"hello\", True)"

  assert result == expected
}

pub fn simple_list_test() {
  let result =
    expression.list([expression.string("hello"), expression.string("hi")])
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "[\"hello\", \"hi\"]"

  assert result == expected
}

pub fn simple_list_prepending_test() {
  let result =
    expression.list_prepend(
      [expression.string("hello"), expression.string("hi")],
      expression.list([expression.string("yo")]),
    )
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "[\"hello\", \"hi\", ..[\"yo\"]]"

  assert result == expected
}

pub fn multiline_list_prepending_test() {
  let result =
    expression.list_prepend(
      [
        expression.string(
          "hello but much, much, much, much longer so it breaks",
        ),
        expression.string(
          "hello but much, much, much, much longer so it breaks",
        ),
      ],
      expression.list([expression.string("yo")]),
    )
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "[
  \"hello but much, much, much, much longer so it breaks\",
  \"hello but much, much, much, much longer so it breaks\",
  ..[\"yo\"]
]"

  assert result == expected
}

pub fn long_list_test() {
  let result =
    expression.list([
      expression.list([
        expression.string("hello"),
        expression.string("hello"),
        expression.string("hello"),
        expression.string("hello"),
        expression.string(
          "hello but much, much, much, much longer so it breaks",
        ),
      ]),
      expression.list([
        expression.string("hi"),
        expression.string("hi"),
        expression.string("hi"),
        expression.string("hi"),
      ]),
    ])
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "[
  [
    \"hello\",
    \"hello\",
    \"hello\",
    \"hello\",
    \"hello but much, much, much, much longer so it breaks\",
  ],
  [\"hi\", \"hi\", \"hi\", \"hi\"],
]"

  assert result == expected
}

pub fn long_tuple_test() {
  let result =
    expression.tuple9(
      expression.int(3),
      expression.string(
        "hello there (making this really long like really long)",
      ),
      expression.bool(True),
      expression.bool(True),
      expression.bool(True),
      expression.bool(True),
      expression.bool(True),
      expression.bool(True),
      expression.bool(True),
    )
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "#(
  3,
  \"hello there (making this really long like really long)\",
  True,
  True,
  True,
  True,
  True,
  True,
  True,
)"

  assert result == expected
}

pub fn simple_float_subtraction_test() {
  let result =
    expression.float(3.3)
    |> expression.math_operator_float(expression.Add, expression.float(5.3))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "3.3 +. 5.3"

  assert result == expected
}

pub fn equals_test() {
  let result =
    expression.string("hi")
    |> expression.equals(expression.string("hello"))
    |> expression.equals(expression.bool(True))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "\"hi\" == \"hello\" == True"

  assert result == expected
}

pub fn simple_string_addition_test() {
  let result =
    expression.string("hello ")
    |> expression.concat_string(expression.string("world"))
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "\"hello \" <> \"world\""

  assert result == expected
}

pub fn simple_field_access_test() {
  let result =
    expression.raw("custom")
    |> expression.field("field")
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected = "custom.field"

  assert result == expected
}
