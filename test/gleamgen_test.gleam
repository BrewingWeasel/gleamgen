import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/result
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

  function.new0(types.int(), fn() { block_expr })
  |> function.to_unchecked()
  |> module.render_function(render.default_context(), "test_function")
  |> render.to_string()
  |> should.equal(
    "fn test_function() -> Int {
  let x = 4
  let y = x + 5
  y
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
        arg1: #("thing", types.string()),
        returns: types.string(),
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
      function.new0(returns: types.nil(), handler: fn() {
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

pub fn module_with_type_alias_test() {
  let mod = {
    use awesome_string <- module.with_type_alias(
      module.DefinitionDetails(
        name: "AwesomeString",
        is_public: False,
        attributes: [],
      ),
      types.string(),
    )

    use _ <- module.with_function(
      module.DefinitionDetails(name: "runner", is_public: True, attributes: [
        module.Internal,
      ]),
      function.new1(
        arg1: #("thing", awesome_string),
        returns: types.string(),
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
      function.new0(returns: types.nil(), handler: fn() {
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

pub type ExampleAnimal {
  ExampleAnimal
}

pub fn module_with_custom_type_test() {
  let animals =
    custom.new(ExampleAnimal)
    |> custom.with_variant(fn(_) {
      variant.new("Dog")
      |> variant.with_argument(option.Some("bones"), types.int())
    })
    |> custom.with_variant(fn(_) {
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), types.string())
      |> variant.with_argument(option.Some("has_catnip"), types.bool())
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
        arg1: #("animal", animal_type),
        returns: types.string(),
        handler: fn(_thing) { expression.todo_(option.Some("implement me")) },
      ),
    )

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(returns: types.nil(), handler: fn() {
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
      |> variant.with_argument(option.Some("bones"), types.int())
    })
    |> custom.with_variant(fn(_) {
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), types.string())
      |> variant.with_argument(option.Some("has_catnip"), types.bool())
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
        arg1: #("animal", animal_type),
        returns: types.string(),
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
      function.new0(returns: types.nil(), handler: fn() {
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

pub fn module_with_custom_type_generics_test() {
  let more_awesome_result =
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
    use _, ok_awesome_constructor, less_ok_awesome_constructor <- module.with_custom_type2(
      module.DefinitionDetails(
        name: "MoreAwesomeResult",
        is_public: True,
        attributes: [],
      ),
      more_awesome_result,
    )

    use _main <- module.with_function(
      module.DefinitionDetails(name: "main", is_public: True, attributes: []),
      function.new0(returns: types.nil(), handler: fn() {
        {
          use _ <- block.with_let_declaration(
            "whoo",
            expression.call1(
              constructor.to_expression1(ok_awesome_constructor),
              expression.int(4) |> expression.to_unchecked(),
            ),
          )
          use _ <- block.with_let_declaration(
            "still_yay",
            expression.call2(
              constructor.to_expression2(less_ok_awesome_constructor),
              expression.string("jake") |> expression.to_unchecked(),
              expression.bool(True) |> expression.to_unchecked(),
            ),
          )
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
    "pub type MoreAwesomeResult(awesome, not_awesome) {
  VeryOk(contents: awesome)
  NotVeryOk(contents: awesome, failures: not_awesome)
}

pub fn main() -> Nil {
  let whoo = VeryOk(4)
  let still_yay = NotVeryOk(\"jake\", True)
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
            types.int() |> types.to_unchecked(),
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
      function.new0(returns: custom_type_type, handler: fn() {
        constructor.to_expression_unchecked(variant0)
      }),
    )
    use _get_other_variant <- module.with_function(
      module.DefinitionDetails(
        name: "get_other_variant",
        is_public: True,
        attributes: [],
      ),
      function.new0(returns: custom_type_type, handler: fn() {
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
