import gleamgen/expression
import gleamgen/expression/case_
import gleamgen/internal/render
import gleamgen/pattern
import gleamgen/render/config

pub fn simple_case_string_test() {
  let result =
    case_.new(expression.string("hello"))
    |> case_.with_pattern(pattern.string_literal("hello"), fn(_) {
      expression.string("world")
    })
    |> case_.with_pattern(pattern.variable("v"), fn(v) {
      expression.concat_string(v, expression.string(" world"))
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case \"hello\" {
  \"hello\" -> \"world\"
  v -> v <> \" world\"
}"

  assert result == expected
}

pub fn simple_case_or_test() {
  let result =
    case_.new(expression.string("hello"))
    |> case_.with_pattern(
      pattern.or(pattern.string_literal("hello"), pattern.string_literal("hi")),
      fn(_) { expression.string("world") },
    )
    |> case_.with_pattern(pattern.variable("v"), fn(v) {
      expression.concat_string(v, expression.string(" world"))
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case \"hello\" {
  \"hello\" | \"hi\" -> \"world\"
  v -> v <> \" world\"
}"

  assert result == expected
}

pub fn simple_case_as_test() {
  let result =
    case_.new(expression.string("hello"))
    |> case_.with_pattern(
      pattern.string_literal("hello")
        |> pattern.as_("greeting"),
      fn(greeting) {
        expression.concat_string(greeting, expression.string("world"))
      },
    )
    |> case_.with_pattern(pattern.variable("v"), fn(v) {
      expression.concat_string(v, expression.string(" world"))
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case \"hello\" {
  \"hello\" as greeting -> greeting <> \"world\"
  v -> v <> \" world\"
}"

  assert result == expected
}

pub fn simple_case_tuple_to_multiple_subjects_test() {
  let result =
    case_.new(expression.tuple2(expression.string("hello"), expression.int(3)))
    |> case_.with_pattern(
      pattern.tuple2(
        pattern.string_literal("hello"),
        pattern.named_discard("other"),
      ),
      fn(_) { expression.string("world") },
    )
    |> case_.with_pattern(pattern.discard(), fn(_: Nil) {
      expression.string("other")
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case \"hello\", 3 {
  \"hello\", _other -> \"world\"
  _, _ -> \"other\"
}"

  assert result == expected
}

pub fn simple_case_tuple_not_multiple_subjects_test() {
  let result =
    case_.new(expression.tuple2(expression.string("hello"), expression.int(3)))
    |> case_.with_pattern(
      pattern.tuple2(pattern.string_literal("hello"), pattern.variable("num")),
      fn(patterns) {
        let #(_, num) = patterns
        expression.tuple2(
          expression.string("world"),
          expression.math_operator(num, expression.Add, expression.int(2)),
        )
      },
    )
    |> case_.with_pattern(
      pattern.variable("my_favorite_variable"),
      fn(my_favorite_variable) { my_favorite_variable },
    )
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case #(\"hello\", 3) {
  #(\"hello\", num) -> #(\"world\", num + 2)
  my_favorite_variable -> my_favorite_variable
}"

  assert result == expected
}

pub fn simple_case_tuple_to_multiple_subjects_multiple_vars_test() {
  let result =
    case_.new(expression.tuple2(expression.string("hello"), expression.int(3)))
    |> case_.with_pattern(
      pattern.tuple2(pattern.string_literal("hello"), pattern.variable("num")),
      fn(patterns) {
        let #(_, num) = patterns
        expression.tuple2(
          expression.string("world"),
          expression.math_operator(num, expression.Add, expression.int(2)),
        )
      },
    )
    |> case_.with_pattern(
      pattern.tuple2(pattern.variable("greeting"), pattern.variable("num")),
      fn(patterns) {
        let #(greeting, num) = patterns
        expression.tuple2(
          greeting,
          expression.math_operator(num, expression.Sub, expression.int(2)),
        )
      },
    )
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case \"hello\", 3 {
  \"hello\", num -> #(\"world\", num + 2)
  greeting, num -> #(greeting, num - 2)
}"

  assert result == expected
}

pub fn simple_case_merge_repeated_test() {
  let result =
    case_.new(expression.string("hello"))
    |> case_.with_pattern(
      pattern.or(pattern.string_literal("hello"), pattern.string_literal("hi")),
      fn(_) { expression.string("...world!") },
    )
    |> case_.with_pattern(pattern.string_literal("hola"), fn(_) {
      expression.string("...world!")
    })
    |> case_.with_pattern(pattern.string_literal("labas"), fn(_) {
      expression.string("...world!")
    })
    |> case_.with_pattern(pattern.string_literal("sveiks"), fn(_) {
      expression.string("Latvian????")
    })
    |> case_.with_pattern(pattern.variable("v"), fn(v) {
      expression.concat_string(v, expression.string(" world"))
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case \"hello\" {
  \"hello\" | \"hi\" | \"hola\" | \"labas\" -> \"...world!\"
  \"sveiks\" -> \"Latvian????\"
  v -> v <> \" world\"
}"

  assert result == expected
}

pub fn case_merge_repeated_test() {
  let result =
    case_.new(expression.string("hello"))
    |> case_.with_pattern(
      pattern.concat_string(starting: "I love ", variable: "thing"),
      fn(thing) {
        expression.concat_string(thing, expression.string("is good!"))
      },
    )
    |> case_.with_pattern(
      pattern.concat_string(
        starting: "My favorite thing is ",
        variable: "thing",
      ),
      fn(thing) {
        expression.concat_string(thing, expression.string("is good!"))
      },
    )
    |> case_.with_pattern(pattern.variable("_"), fn(_) {
      expression.string("I don't know!")
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case \"hello\" {
  \"I love \" <> thing | \"My favorite thing is \" <> thing -> thing <> \"is good!\"
  _ -> \"I don't know!\"
}"

  assert result == expected
}

pub fn case_merge_repeated_config_disabled_test() {
  let result =
    case_.new(expression.string("hello"))
    |> case_.with_pattern(
      pattern.concat_string(starting: "I love ", variable: "thing"),
      fn(thing) {
        expression.concat_string(thing, expression.string("is good!"))
      },
    )
    |> case_.with_pattern(
      pattern.concat_string(
        starting: "My favorite thing is ",
        variable: "thing",
      ),
      fn(thing) {
        expression.concat_string(thing, expression.string("is good!"))
      },
    )
    |> case_.with_pattern(pattern.variable("_"), fn(_) {
      expression.string("I don't know!")
    })
    |> case_.build_expression()
    |> expression.render(render.context_from_config(
      config.Config(..config.default_config, combine_equivalent_branches: False),
    ))
    |> render.to_string()

  let expected =
    "case \"hello\" {
  \"I love \" <> thing -> thing <> \"is good!\"
  \"My favorite thing is \" <> thing -> thing <> \"is good!\"
  _ -> \"I don't know!\"
}"

  assert result == expected
}

pub fn simple_string_concat_test() {
  let result =
    case_.new(expression.string("I love gleam"))
    |> case_.with_pattern(
      pattern.concat_string(starting: "I love ", variable: "thing"),
      fn(thing) {
        expression.string("I love ")
        |> expression.concat_string(thing)
        |> expression.concat_string(expression.string(" too"))
      },
    )
    |> case_.with_pattern(pattern.variable("_"), fn(_) {
      expression.string("Interesting")
    })
    |> case_.build_expression()
    |> expression.render(render.default_context())
    |> render.to_string()

  let expected =
    "case \"I love gleam\" {
  \"I love \" <> thing -> \"I love \" <> thing <> \" too\"
  _ -> \"Interesting\"
}"

  assert result == expected
}
