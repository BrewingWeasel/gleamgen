import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/expression/case_
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/import_
import gleamgen/matcher
import gleamgen/module
import gleamgen/render
import gleamgen/types
import gleamgen/types/custom
import gleamgen/types/variant
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn simple_int_addition_test() {
  expression.int(3)
  |> expression.math_operator(expression.Add, expression.int(5))
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("3 + 5")
}

pub fn simple_string_test() {
  expression.string("hello")
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("\"hello\"")
}

pub fn string_escape_quote_test() {
  expression.string("hel\"lo")
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("\"hel\\\"lo\"")
}

pub fn string_escape_slash_test() {
  expression.string("hello\\hi")
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("\"hello\\hi\"")
}

pub fn empty_string_test() {
  expression.string("")
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("\"\"")
}

pub fn simple_tuple_test() {
  expression.tuple3(
    expression.int(3),
    expression.string("hello"),
    expression.bool(True),
  )
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("#(3, \"hello\", True)")
}

pub fn simple_list_test() {
  expression.list([expression.string("hello"), expression.string("hi")])
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("[\"hello\", \"hi\"]")
}

pub fn simple_list_prepending_test() {
  expression.list_prepend(
    [expression.string("hello"), expression.string("hi")],
    expression.list([expression.string("yo")]),
  )
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("[\"hello\", \"hi\", ..[\"yo\"]]")
}

pub fn multiline_list_prepending_test() {
  expression.list_prepend(
    [
      expression.string("hello but much, much, much, much longer so it breaks"),
      expression.string("hello but much, much, much, much longer so it breaks"),
    ],
    expression.list([expression.string("yo")]),
  )
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "[
  \"hello but much, much, much, much longer so it breaks\",
  \"hello but much, much, much, much longer so it breaks\",
  ..[\"yo\"]
]",
  )
}

pub fn long_list_test() {
  expression.list([
    expression.list([
      expression.string("hello"),
      expression.string("hello"),
      expression.string("hello"),
      expression.string("hello"),
      expression.string("hello but much, much, much, much longer so it breaks"),
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
  |> should.equal(
    "[
  [
    \"hello\",
    \"hello\",
    \"hello\",
    \"hello\",
    \"hello but much, much, much, much longer so it breaks\",
  ],
  [\"hi\", \"hi\", \"hi\", \"hi\"],
]",
  )
}

pub fn long_tuple_test() {
  expression.tuple9(
    expression.int(3),
    expression.string("hello there (making this really long like really long)"),
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
  |> should.equal(
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
)",
  )
}

pub fn simple_todo_test() {
  expression.todo_(option.Some("some unimplemented thing"))
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("todo as \"some unimplemented thing\"")
}

pub fn simple_float_subtraction_test() {
  expression.float(3.3)
  |> expression.math_operator_float(expression.Add, expression.float(5.3))
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("3.3 +. 5.3")
}

pub fn equals_test() {
  expression.string("hi")
  |> expression.equals(expression.string("hello"))
  |> expression.equals(expression.bool(True))
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("\"hi\" == \"hello\" == True")
}

pub fn simple_string_addition_test() {
  expression.string("hello ")
  |> expression.concat_string(expression.string("world"))
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal("\"hello \" <> \"world\"")
}

pub fn simple_case_string_test() {
  case_.new(expression.string("hello"))
  |> case_.with_matcher(matcher.string_literal("hello"), fn(_) {
    expression.string("world")
  })
  |> case_.with_matcher(matcher.variable("v"), fn(v) {
    expression.concat_string(v, expression.string(" world"))
  })
  |> case_.build_expression()
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "case \"hello\" {
  \"hello\" -> \"world\"
  v -> v <> \" world\"
}",
  )
}

pub fn simple_case_or_test() {
  case_.new(expression.string("hello"))
  |> case_.with_matcher(
    matcher.or(matcher.string_literal("hello"), matcher.string_literal("hi")),
    fn(_) { expression.string("world") },
  )
  |> case_.with_matcher(matcher.variable("v"), fn(v) {
    expression.concat_string(v, expression.string(" world"))
  })
  |> case_.build_expression()
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "case \"hello\" {
  \"hello\" | \"hi\" -> \"world\"
  v -> v <> \" world\"
}",
  )
}

pub fn simple_case_as_test() {
  case_.new(expression.string("hello"))
  |> case_.with_matcher(
    matcher.string_literal("hello")
      |> matcher.as_("greeting"),
    fn(greeting) {
      expression.concat_string(greeting, expression.string("world"))
    },
  )
  |> case_.with_matcher(matcher.variable("v"), fn(v) {
    expression.concat_string(v, expression.string(" world"))
  })
  |> case_.build_expression()
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "case \"hello\" {
  \"hello\" as greeting -> greeting <> \"world\"
  v -> v <> \" world\"
}",
  )
}

pub fn simple_string_concat_test() {
  case_.new(expression.string("I love gleam"))
  |> case_.with_matcher(
    matcher.concat_string(starting: "I love ", variable: "thing"),
    fn(thing) {
      expression.string("I love ")
      |> expression.concat_string(thing)
      |> expression.concat_string(expression.string(" too"))
    },
  )
  |> case_.with_matcher(matcher.variable("_"), fn(_) {
    expression.string("Interesting")
  })
  |> case_.build_expression()
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "case \"I love gleam\" {
  \"I love \" <> thing -> \"I love \" <> thing <> \" too\"
  _ -> \"Interesting\"
}",
  )
}

pub fn simple_case_tuple_test() {
  case_.new(expression.tuple2(expression.string("hello"), expression.int(3)))
  |> case_.with_matcher(
    matcher.tuple2(matcher.string_literal("hello"), matcher.variable("_")),
    fn(_) { expression.string("world") },
  )
  |> case_.with_matcher(matcher.variable("_"), fn(_) {
    expression.string("other")
  })
  |> case_.build_expression()
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "case #(\"hello\", 3) {
  #(\"hello\", _) -> \"world\"
  _ -> \"other\"
}",
  )
}

pub fn simple_block_test() {
  {
    use x <- block.with_let_declaration("x", expression.int(4))
    use y <- block.with_let_declaration(
      "y",
      expression.math_operator(x, expression.Add, expression.int(5)),
    )
    block.ending_block(y)
  }
  |> block.build()
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "{
  let x = 4
  let y = x + 5
  y
}",
  )
}

pub fn block_in_function_test() {
  let block_expr =
    {
      use x <- block.with_let_declaration("x", expression.int(4))
      use y <- block.with_let_declaration(
        "y",
        expression.math_operator(x, expression.Add, expression.int(5)),
      )
      block.ending_block(y)
    }
    |> block.build()

  function.new0(types.int, fn() { block_expr })
  |> function.to_unchecked()
  |> function.render(render.default_context(), option.Some("test_function"))
  |> render.to_string()
  |> should.equal(
    "fn test_function() -> Int {
  let x = 4
  let y = x + 5
  y
}",
  )
}

pub fn simple_anonymous_function_test() {
  {
    use func <- block.with_let_declaration(
      "func",
      function.anonymous(
        function.new2(
          #("x", types.int),
          #("y", types.int),
          types.int,
          handler: fn(x, y) { expression.math_operator(x, expression.Add, y) },
        ),
      ),
    )
    block.ending_block(expression.call2(
      func,
      expression.int(2),
      expression.int(3),
    ))
  }
  |> block.build()
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "{
  let func = fn(x: Int, y: Int) -> Int { x + y }
  func(2, 3)
}",
  )
}

pub fn simple_module_test() {
  let mod =
    module.Module(
      [
        module.Definition(
          details: module.DefinitionDetails(
            name: "based_number",
            is_public: True,
            attributes: [],
          ),
          value: module.Constant(
            expression.int(46) |> expression.to_unchecked(),
          ),
        ),
      ],
      [],
    )
  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal("pub const based_number = 46")
}

pub fn block_with_let_matching_test() {
  {
    use x <- block.with_let_declaration("x", expression.ok(expression.int(4)))
    use y <- block.with_matching_let_declaration(
      matcher.or(
        matcher.ok(matcher.variable("y")),
        matcher.error(matcher.variable("y")),
      ),
      x,
      False,
    )
    block.ending_block(expression.math_operator(
      y,
      expression.Add,
      expression.int(3),
    ))
  }
  |> block.build()
  |> expression.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "{
  let x = Ok(4)
  let Ok(y) | Error(y) = x
  y + 3
}",
  )
}

pub fn module_with_function_test() {
  let mod = {
    use io <- module.with_import(import_.new(["gleam", "io"]))
    use language <- module.with_constant(
      module.DefinitionDetails(
        name: "language",
        is_public: False,
        attributes: [],
      ),
      expression.string("gleam"),
    )

    use describer <- module.with_function(
      module.DefinitionDetails(name: "describer", is_public: True, attributes: [
        module.Internal,
      ]),
      function.new1(
        arg1: #("thing", types.string),
        returns: types.string,
        handler: fn(thing) {
          expression.string("The ")
          |> expression.concat_string(thing)
          |> expression.concat_string(expression.string(" is written in "))
          |> expression.concat_string(language)
        },
      ),
    )

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(returns: types.nil, handler: fn() {
        expression.call1(
          import_.unchecked_ident(io, "println"),
          expression.call1(describer, expression.string("program")),
        )
      }),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/io

const language = \"gleam\"

@internal
pub fn describer(thing: String) -> String {
  \"The \" <> thing <> \" is written in \" <> language
}

pub fn main() -> Nil {
  io.println(describer(\"program\"))
}",
  )
}

pub fn module_import_constructor_test() {
  let mod = {
    use option_module <- module.with_import(import_.new(["gleam", "option"]))

    let option_type = import_.unchecked_type(option_module, "Option")

    use _option_from_str <- module.with_function(
      module.DefinitionDetails(
        name: "option_from_string",
        is_public: True,
        attributes: [],
      ),
      function.new1(
        arg1: #("str", types.string),
        returns: option_type |> custom.to_type1(types.string),
        handler: fn(str) {
          case_.new(str)
          |> case_.with_matcher(matcher.string_literal(""), fn(_) {
            expression.construct0(import_.value_of_type(
              option_module,
              "None",
              types.function0(option_type |> custom.to_type1(types.string)),
            ))
          })
          |> case_.with_matcher(matcher.variable("value"), fn(value) {
            expression.construct1(
              import_.value_of_type(
                option_module,
                "Some",
                types.function1(
                  types.string,
                  option_type |> custom.to_type1(types.string),
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

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/option

pub fn option_from_string(str: String) -> option.Option(String) {
  case str {
    \"\" -> option.None
    value -> option.Some(value)
  }
}",
  )
}

pub fn basic_use_test() {
  let mod = {
    use result_module <- module.with_import(import_.new(["gleam", "result"]))

    use _ <- module.with_function(
      module.DefinitionDetails(
        name: "do_result",
        is_public: True,
        attributes: [],
      ),
      function.new0(
        returns: types.result(types.int, types.string),
        handler: fn() {
          let block = {
            use res <- block.with_let_declaration(
              "res",
              expression.ok(expression.int(3)),
            )
            use ok_value <- block.with_use1(
              block.use_function1(
                import_.function2(result_module, result.try),
                res,
              ),
              "ok_value",
            )

            block.ending_block(
              ok_value
              |> expression.math_operator(expression.Add, expression.int(5))
              |> expression.ok,
            )
          }
          block.build(block)
        },
      ),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/result

pub fn do_result() -> Result(Int, String) {
  let res = Ok(3)
  use ok_value <- result.try(res)
  Ok(ok_value + 5)
}",
  )
}

pub fn two_use_test() {
  let mod = {
    use result_module <- module.with_import(import_.new(["gleam", "result"]))
    use bool_module <- module.with_import(import_.new(["gleam", "bool"]))

    use _ <- module.with_function(
      module.DefinitionDetails(
        name: "do_result",
        is_public: True,
        attributes: [],
      ),
      function.new0(
        returns: types.result(types.int, types.string),
        handler: fn() {
          let block = {
            use res <- block.with_let_declaration(
              "res",
              expression.ok(expression.int(3)),
            )

            use ok_value <- block.with_use1(
              block.use_function1(
                import_.function2(result_module, result.try),
                res,
              ),
              "ok_value",
            )

            use <- block.with_use0(block.use_function2(
              import_.function3(bool_module, bool.guard),
              expression.equals(ok_value, expression.int(2)),
              expression.error(expression.string("not equal to 2")),
            ))

            block.ending_block(
              ok_value
              |> expression.math_operator(expression.Add, expression.int(5))
              |> expression.ok,
            )
          }
          block.build(block)
        },
      ),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/bool
import gleam/result

pub fn do_result() -> Result(Int, String) {
  let res = Ok(3)
  use ok_value <- result.try(res)
  use <- bool.guard(ok_value == 2, Error(\"not equal to 2\"))
  Ok(ok_value + 5)
}",
  )
}

pub fn result_test() {
  let mod = {
    use result_module <- module.with_import(import_.new(["gleam", "result"]))
    use string_module <- module.with_import(import_.new(["gleam", "string"]))

    use _swap_result <- module.with_function(
      module.DefinitionDetails(
        name: "handle_result",
        is_public: True,
        attributes: [],
      ),
      function.new1(
        arg1: #("res", types.result(types.string, types.int)),
        returns: types.result(types.bool, types.int),
        handler: fn(res) {
          let block = {
            use _ <- block.with_let_declaration(
              "v",
              expression.call2(
                import_.function2(result_module, result.unwrap),
                expression.ok(expression.string("hi")),
                expression.string("hey"),
              ),
            )

            let special_matcher =
              matcher.or(
                matcher.ok(matcher.string_literal("")),
                matcher.error(matcher.int_literal(0)),
              )

            block.ending_block(
              case_.new(res)
              |> case_.with_matcher(special_matcher, fn(_) {
                expression.ok(expression.bool(True))
              })
              |> case_.with_matcher(
                matcher.ok(matcher.variable("str")),
                fn(str) {
                  expression.call1(
                    import_.function1(string_module, string.length),
                    str,
                  )
                  |> expression.error()
                },
              )
              |> case_.with_matcher(
                matcher.error(matcher.variable("number")),
                fn(number) { expression.error(number) },
              )
              |> case_.build_expression(),
            )
          }
          block |> block.build()
        },
      ),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/result
import gleam/string

pub fn handle_result(res: Result(String, Int)) -> Result(Bool, Int) {
  let v = result.unwrap(Ok(\"hi\"), \"hey\")
  case res {
    Ok(\"\") | Error(0) -> Ok(True)
    Ok(str) -> Error(string.length(str))
    Error(number) -> Error(number)
  }
}",
  )
}

pub fn module_with_type_alias_test() {
  let mod = {
    use awesome_string <- module.with_type_alias(
      module.DefinitionDetails(
        name: "AwesomeString",
        is_public: False,
        attributes: [],
      ),
      types.string,
    )

    use _ <- module.with_function(
      module.DefinitionDetails(name: "runner", is_public: True, attributes: [
        module.Internal,
      ]),
      function.new1(
        arg1: #("thing", awesome_string),
        returns: types.string,
        handler: fn(thing) {
          expression.string("Hi ")
          |> expression.concat_string(thing)
        },
      ),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "type AwesomeString = String

@internal
pub fn runner(thing: AwesomeString) -> String {
  \"Hi \" <> thing
}",
  )
}

pub fn module_import_test() {
  let mod = {
    use io <- module.with_import(import_.new_with_alias(
      ["gleam", "io"],
      "only_o",
    ))
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))

    let io_print = import_.function1(io, io.println)
    let int_string = import_.function1(int_mod, int.to_string)

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(returns: types.nil, handler: fn() {
        expression.call1(
          io_print,
          expression.call1(int_string, expression.int(23)),
        )
      }),
    )
    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/int
import gleam/io as only_o

pub fn main() -> Nil {
  only_o.println(int.to_string(23))
}",
  )
}

pub fn module_unused_import_test() {
  let mod = {
    use io <- module.with_import(import_.new_with_alias(
      ["gleam", "io"],
      "only_o",
    ))
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use _ <- module.with_import(import_.new(["gleam", "string"]))

    let io_print = import_.function1(io, io.println)
    let int_string = import_.function1(int_mod, int.to_string)

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(returns: types.nil, handler: fn() {
        expression.call1(
          io_print,
          expression.call1(int_string, expression.int(23)),
        )
      }),
    )
    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/int
import gleam/io as only_o

pub fn main() -> Nil {
  only_o.println(int.to_string(23))
}",
  )
}

pub fn module_sometimes_unused_import_test() {
  let mod = {
    use io <- module.with_import(import_.new_with_alias(
      ["gleam", "io"],
      "only_o",
    ))
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use string_mod <- module.with_import(import_.new(["gleam", "string"]))

    let io_print = import_.function1(io, io.println)
    let int_string = import_.function1(int_mod, int.to_string)
    let string_length = import_.function1(string_mod, string.length)

    // Because this is False, we don't use the string module, 
    // therefore it should not be rendered in the final string
    let use_string_mod_this_time = 1 == 0

    let int_value = case use_string_mod_this_time {
      True -> expression.call1(string_length, expression.string("hi"))
      False -> expression.int(23)
    }

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(returns: types.nil, handler: fn() {
        expression.call1(io_print, expression.call1(int_string, int_value))
      }),
    )
    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/int
import gleam/io as only_o

pub fn main() -> Nil {
  only_o.println(int.to_string(23))
}",
  )
}

pub type ExampleAnimal {
  ExampleAnimal
}

pub fn module_with_custom_type_test() {
  let animals =
    custom.new(ExampleAnimal)
    |> custom.with_variant(fn(_) {
      variant.new("Dog")
      |> variant.with_argument(option.Some("bones"), types.int)
    })
    |> custom.with_variant(fn(_) {
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), types.string)
      |> variant.with_argument(option.Some("has_catnip"), types.bool)
    })

  let mod = {
    use animal_type, dog_constructor, cat_constructor <- module.with_custom_type2(
      module.DefinitionDetails(name: "Animal", is_public: True, attributes: []),
      animals,
    )

    use describer <- module.with_function(
      module.DefinitionDetails(
        name: "describer",
        is_public: True,
        attributes: [],
      ),
      function.new1(
        arg1: #("animal", animal_type |> custom.to_type()),
        returns: types.string,
        handler: fn(_thing) { expression.todo_(option.Some("implement me")) },
      ),
    )

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(returns: types.nil, handler: fn() {
        {
          use dog_var <- block.with_let_declaration(
            "dog",
            expression.construct1(
              constructor.to_expression1(dog_constructor),
              expression.int(4),
            ),
          )
          use <- block.with_expression(expression.call1(describer, dog_var))
          use cat_var <- block.with_let_declaration(
            "cat",
            expression.construct2(
              constructor.to_expression2(cat_constructor),
              expression.string("jake"),
              expression.bool(True),
            ),
          )
          use <- block.with_expression(expression.call1(describer, cat_var))
          block.ending_unchecked([])
        }
        |> block.build()
      }),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "pub type Animal {
  Dog(bones: Int)
  Cat(name: String, has_catnip: Bool)
}

pub fn describer(animal: Animal) -> String {
  todo as \"implement me\"
}

pub fn main() -> Nil {
  let dog = Dog(4)
  describer(dog)
  let cat = Cat(\"jake\", True)
  describer(cat)
}",
  )
}

pub fn module_case_on_custom_type_test() {
  let animals =
    custom.new(ExampleAnimal)
    |> custom.with_variant(fn(_) {
      variant.new("Dog")
      |> variant.with_argument(option.Some("bones"), types.int)
    })
    |> custom.with_variant(fn(_) {
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), types.string)
      |> variant.with_argument(option.Some("has_catnip"), types.bool)
    })

  let mod = {
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use animal_type, dog_constructor, cat_constructor <- module.with_custom_type2(
      module.DefinitionDetails(name: "Animal", is_public: True, attributes: []),
      animals,
    )

    use describer <- module.with_function(
      module.DefinitionDetails(
        name: "describer",
        is_public: True,
        attributes: [],
      ),
      function.new1(
        arg1: #("animal", animal_type |> custom.to_type()),
        returns: types.string,
        handler: fn(animal) {
          case_.new(animal)
          |> case_.with_matcher(
            matcher.from_constructor1(
              dog_constructor,
              matcher.variable("bones"),
            ),
            fn(bones) {
              expression.string("Dog with ")
              |> expression.concat_string(expression.call1(
                import_.function1(int_mod, int.to_string),
                bones,
              ))
            },
          )
          |> case_.with_matcher(
            matcher.from_constructor2(
              cat_constructor,
              matcher.variable("name"),
              matcher.bool_literal(True),
            ),
            fn(info) {
              let #(name, Nil) = info
              expression.string("Cat named ")
              |> expression.concat_string(name)
              |> expression.concat_string(expression.string(" (energetic!)"))
            },
          )
          |> case_.with_matcher(
            matcher.from_constructor2(
              cat_constructor,
              matcher.variable("name"),
              matcher.bool_literal(False),
            ),
            fn(info) {
              let #(name, Nil) = info
              expression.string("Bored cat named ")
              |> expression.concat_string(name)
            },
          )
          |> case_.build_expression()
        },
      ),
    )

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(returns: types.nil, handler: fn() {
        {
          use dog_var <- block.with_let_declaration(
            "dog",
            expression.call1(
              constructor.to_expression1(dog_constructor),
              expression.int(4),
            ),
          )
          use <- block.with_expression(expression.call1(describer, dog_var))
          use cat_var <- block.with_let_declaration(
            "cat",
            expression.call2(
              constructor.to_expression2(cat_constructor),
              expression.string("jake"),
              expression.bool(True),
            ),
          )
          use <- block.with_expression(expression.call1(describer, cat_var))
          block.ending_unchecked([])
        }
        |> block.build()
      }),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/int

pub type Animal {
  Dog(bones: Int)
  Cat(name: String, has_catnip: Bool)
}

pub fn describer(animal: Animal) -> String {
  case animal {
    Dog(bones) -> \"Dog with \" <> int.to_string(bones)
    Cat(name, True) -> \"Cat named \" <> name <> \" (energetic!)\"
    Cat(name, False) -> \"Bored cat named \" <> name
  }
}

pub fn main() -> Nil {
  let dog = Dog(4)
  describer(dog)
  let cat = Cat(\"jake\", True)
  describer(cat)
}",
  )
}

pub fn module_let_on_custom_type_test() {
  let animals =
    custom.new(ExampleAnimal)
    |> custom.with_variant(fn(_) {
      variant.new("Dog")
      |> variant.with_argument(option.Some("bones"), types.int)
    })
    |> custom.with_variant(fn(_) {
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), types.string)
      |> variant.with_argument(option.Some("has_catnip"), types.bool)
    })

  let mod = {
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use _animal_type, dog_constructor, cat_constructor <- module.with_custom_type2(
      module.DefinitionDetails(name: "Animal", is_public: True, attributes: []),
      animals,
    )

    use _describe <- module.with_function(
      module.DefinitionDetails(
        name: "describe",
        is_public: True,
        attributes: [],
      ),
      function.new0(returns: types.string, handler: fn() {
        {
          use bones <- block.with_matching_let_declaration(
            matcher.from_constructor1(
              dog_constructor,
              matcher.variable("bones"),
            ),
            expression.construct1(
              constructor.to_expression1(dog_constructor),
              expression.int(4),
            ),
            True,
          )

          use #(name, Nil) <- block.with_matching_let_declaration(
            matcher.from_constructor2(
              cat_constructor,
              matcher.as_(matcher.string_literal("jake"), "name"),
              matcher.bool_literal(True),
            ),
            expression.construct2(
              constructor.to_expression2(cat_constructor),
              expression.string("jake"),
              expression.bool(True),
            ),
            True,
          )
          block.ending_block(expression.concat_string(
            expression.concat_string(
              name,
              expression.string(" knows a dog with this many bones: "),
            ),
            expression.call1(import_.function1(int_mod, int.to_string), bones),
          ))
        }
        |> block.build()
      }),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/int

pub type Animal {
  Dog(bones: Int)
  Cat(name: String, has_catnip: Bool)
}

pub fn describe() -> String {
  let assert Dog(bones) = Dog(4)
  let assert Cat(\"jake\" as name, True) = Cat(\"jake\", True)
  name <> \" knows a dog with this many bones: \" <> int.to_string(bones)
}",
  )
}

pub fn module_with_custom_type_generics_test() {
  let more_awesome_result: custom.CustomTypeBuilder(Nil, _, _) =
    custom.new(Nil)
    |> custom.with_generic("awesome")
    |> custom.with_generic("not_awesome")
    |> custom.with_variant(fn(generics) {
      let #(#(#(), awesome), _not_awesome) = generics
      variant.new("VeryOk")
      |> variant.with_argument(option.Some("contents"), awesome)
    })
    |> custom.with_variant(fn(generics) {
      let #(#(#(), awesome), not_awesome) = generics
      variant.new("NotVeryOk")
      |> variant.with_argument(option.Some("contents"), awesome)
      |> variant.with_argument(option.Some("failures"), not_awesome)
    })

  let mod = {
    use awesome_type, ok_awesome_constructor, less_ok_awesome_constructor <- module.with_custom_type2(
      module.DefinitionDetails(
        name: "MoreAwesomeResult",
        is_public: True,
        attributes: [],
      ),
      more_awesome_result,
    )

    use _main <- module.with_function(
      module.DefinitionDetails(
        name: "generate",
        is_public: True,
        attributes: [],
      ),
      function.new0(
        returns: custom.to_type2(awesome_type, types.int, types.bool),
        handler: fn() {
          {
            use _ <- block.with_let_declaration(
              "whoo",
              expression.call1(
                constructor.to_expression1(ok_awesome_constructor),
                expression.int(4),
              ),
            )
            block.ending_block(expression.call2(
              constructor.to_expression2(less_ok_awesome_constructor),
              expression.int(23),
              expression.bool(True),
            ))
          }
          |> block.build()
        },
      ),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "pub type MoreAwesomeResult(awesome, not_awesome) {
  VeryOk(contents: awesome)
  NotVeryOk(contents: awesome, failures: not_awesome)
}

pub fn generate() -> MoreAwesomeResult(Int, Bool) {
  let whoo = VeryOk(4)
  NotVeryOk(23, True)
}",
  )
}

pub fn module_with_custom_type_generics_multiple_ways_test() {
  let more_awesome_result: custom.CustomTypeBuilder(
    Nil,
    _,
    custom.Generics2(types.GeneratedType(a), types.GeneratedType(b)),
  ) =
    custom.new(Nil)
    |> custom.with_generic("awesome")
    |> custom.with_generic("not_awesome")
    |> custom.with_variant(fn(generics) {
      let #(#(#(), awesome), _not_awesome) = generics
      variant.new("VeryOk")
      |> variant.with_argument(option.Some("contents"), awesome)
    })
    |> custom.with_variant(fn(generics) {
      let #(#(#(), awesome), not_awesome) = generics
      variant.new("NotVeryOk")
      |> variant.with_argument(option.Some("contents"), awesome)
      |> variant.with_argument(option.Some("failures"), not_awesome)
    })

  let mod = {
    use awesome_type, base_ok_constructor, base_less_ok_constructor <- module.with_custom_type2(
      module.DefinitionDetails(
        name: "MoreAwesomeResult",
        is_public: True,
        attributes: [],
      ),
      more_awesome_result,
    )

    let first_ok_constructor: constructor.Constructor(
      Nil,
      _,
      custom.Generics2(types.GeneratedType(Int), types.GeneratedType(String)),
    ) = constructor.unsafe_convert(base_ok_constructor)

    let less_ok_constructor: constructor.Constructor(
      Nil,
      _,
      custom.Generics2(types.GeneratedType(String), types.GeneratedType(Bool)),
    ) = constructor.unsafe_convert(base_less_ok_constructor)

    use _main <- module.with_function(
      module.DefinitionDetails(
        name: "generate",
        is_public: True,
        attributes: [],
      ),
      function.new0(
        returns: custom.to_type2(awesome_type, types.string, types.bool),
        handler: fn() {
          {
            use _ <- block.with_let_declaration(
              "whoo",
              expression.call1(
                constructor.to_expression1(first_ok_constructor),
                expression.int(4),
              ),
            )
            block.ending_block(expression.call2(
              constructor.to_expression2(less_ok_constructor),
              expression.string("hi"),
              expression.bool(True),
            ))
          }
          |> block.build()
        },
      ),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "pub type MoreAwesomeResult(awesome, not_awesome) {
  VeryOk(contents: awesome)
  NotVeryOk(contents: awesome, failures: not_awesome)
}

pub fn generate() -> MoreAwesomeResult(String, Bool) {
  let whoo = VeryOk(4)
  NotVeryOk(\"hi\", True)
}",
  )
}

pub fn case_unchecked_variant_test() {
  let custom_variant =
    variant.new("CustomVariant")
    |> variant.with_arguments_unchecked(
      list.range(0, 10)
      |> list.map(fn(x) {
        #(
          option.Some("arg" <> int.to_string(x)),
          types.int |> types.to_unchecked(),
        )
      }),
    )
    |> variant.to_unchecked()

  let custom_type =
    custom.new(#())
    |> custom.with_unchecked_variants(fn(_) { [custom_variant] })

  let mod = {
    use int_module <- module.with_import(import_.new(["gleam", "int"]))

    use _, custom_constructors <- module.with_custom_type_unchecked(
      module.DefinitionDetails(
        name: "VariantHolder",
        is_public: True,
        attributes: [],
      ),
      custom_type,
    )
    let assert [custom_variant, ..] = custom_constructors

    let match_on =
      expression.call_unchecked(
        constructor.to_expression_unchecked(custom_variant),
        list.range(0, 15)
          |> list.map(fn(x) {
            expression.int(x + 4) |> expression.to_unchecked()
          }),
      )

    use _ <- module.with_function(
      module.DefinitionDetails(name: "handle", is_public: True, attributes: []),
      function.new0(returns: types.int, handler: fn() {
        case_.new(match_on)
        |> case_.with_matcher(
          matcher.from_constructor_unchecked(
            custom_variant,
            list.range(0, 15)
              |> list.map(fn(x) {
                case x % 2 {
                  0 ->
                    matcher.int_literal(x + 4)
                    |> matcher.to_unchecked()
                  _ ->
                    matcher.variable("value" <> int.to_string(x))
                    |> matcher.to_unchecked()
                }
              }),
          ),
          fn(details) {
            expression.call1(
              import_.function1(int_module, int.sum),
              expression.list(details)
                |> expression.unsafe_from_unchecked(),
            )
          },
        )
        |> case_.with_matcher(matcher.variable("v"), fn(_) {
          // expression.concat_string(v, expression.string(" world"))
          expression.int(5)
        })
        |> case_.build_expression()
      }),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "import gleam/int

pub type VariantHolder {
  CustomVariant(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
  )
}

pub fn handle() -> Int {
  case CustomVariant(4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19) {
    CustomVariant(
      4,
      value1,
      6,
      value3,
      8,
      value5,
      10,
      value7,
      12,
      value9,
      14,
      value11,
      16,
      value13,
      18,
      value15,
    )
    ->
    int.sum([value1, value3, value5, value7, value9, value11, value13, value15])
    v -> 5
  }
}",
  )
}

pub fn module_with_unchecked_custom_types_test() {
  let all_variants =
    list.range(0, 20)
    |> list.map(fn(i) {
      variant.new("Variant" <> int.to_string(i))
      |> variant.with_arguments_unchecked(
        list.range(0, i)
        |> list.reverse()
        |> list.pop(fn(_) { True })
        |> result.map(fn(x) { x.1 })
        |> result.unwrap([])
        |> list.reverse()
        |> list.map(fn(x) {
          #(
            option.Some("arg" <> int.to_string(x)),
            types.int |> types.to_unchecked(),
          )
        }),
      )
      |> variant.to_unchecked()
    })

  let custom_type =
    custom.new(#())
    |> custom.with_unchecked_variants(fn(_) { all_variants })

  let mod = {
    use custom_type_type, custom_constructors <- module.with_custom_type_unchecked(
      module.DefinitionDetails(
        name: "VariantHolder",
        is_public: True,
        attributes: [],
      ),
      custom_type,
    )

    let assert [variant0, _, _, variant3, ..] = custom_constructors

    use _get_variant <- module.with_function(
      module.DefinitionDetails(
        name: "get_variant",
        is_public: True,
        attributes: [],
      ),
      function.new0(returns: custom.to_type(custom_type_type), handler: fn() {
        constructor.to_expression_unchecked(variant0)
      }),
    )
    use _get_other_variant <- module.with_function(
      module.DefinitionDetails(
        name: "get_other_variant",
        is_public: True,
        attributes: [],
      ),
      function.new0(returns: custom.to_type(custom_type_type), handler: fn() {
        expression.call3(
          constructor.to_expression_unchecked(variant3),
          expression.int(1),
          expression.int(2),
          expression.int(3),
        )
      }),
    )

    module.eof()
  }

  mod
  |> module.render(render.default_context())
  |> render.to_string()
  |> should.equal(
    "pub type VariantHolder {
  Variant0
  Variant1(arg0: Int)
  Variant2(arg0: Int, arg1: Int)
  Variant3(arg0: Int, arg1: Int, arg2: Int)
  Variant4(arg0: Int, arg1: Int, arg2: Int, arg3: Int)
  Variant5(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int)
  Variant6(arg0: Int, arg1: Int, arg2: Int, arg3: Int, arg4: Int, arg5: Int)
  Variant7(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
  )
  Variant8(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
  )
  Variant9(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
  )
  Variant10(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
  )
  Variant11(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
  )
  Variant12(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
  )
  Variant13(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
    arg12: Int,
  )
  Variant14(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
    arg12: Int,
    arg13: Int,
  )
  Variant15(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
    arg12: Int,
    arg13: Int,
    arg14: Int,
  )
  Variant16(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
    arg12: Int,
    arg13: Int,
    arg14: Int,
    arg15: Int,
  )
  Variant17(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
    arg12: Int,
    arg13: Int,
    arg14: Int,
    arg15: Int,
    arg16: Int,
  )
  Variant18(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
    arg12: Int,
    arg13: Int,
    arg14: Int,
    arg15: Int,
    arg16: Int,
    arg17: Int,
  )
  Variant19(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
    arg12: Int,
    arg13: Int,
    arg14: Int,
    arg15: Int,
    arg16: Int,
    arg17: Int,
    arg18: Int,
  )
  Variant20(
    arg0: Int,
    arg1: Int,
    arg2: Int,
    arg3: Int,
    arg4: Int,
    arg5: Int,
    arg6: Int,
    arg7: Int,
    arg8: Int,
    arg9: Int,
    arg10: Int,
    arg11: Int,
    arg12: Int,
    arg13: Int,
    arg14: Int,
    arg15: Int,
    arg16: Int,
    arg17: Int,
    arg18: Int,
    arg19: Int,
  )
}

pub fn get_variant() -> VariantHolder {
  Variant0
}

pub fn get_other_variant() -> VariantHolder {
  Variant3(1, 2, 3)
}",
  )
}
