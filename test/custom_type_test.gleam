import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/expression/case_
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/import_
import gleamgen/internal/render
import gleamgen/module
import gleamgen/module/definition
import gleamgen/parameter
import gleamgen/pattern
import gleamgen/type_
import gleamgen/type_/custom
import gleamgen/type_/variant

pub type ExampleAnimal {
  ExampleAnimal
}

pub fn module_with_custom_type_test() {
  let animals =
    custom.new(ExampleAnimal)
    |> custom.with_variant(fn(_) {
      variant.new("Dog")
      |> variant.with_argument(option.Some("bones"), type_.int)
    })
    |> custom.with_variant(fn(_) {
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), type_.string)
      |> variant.with_argument(option.Some("has_catnip"), type_.bool)
    })

  let mod = {
    use animal_type, dog_constructor, cat_constructor <- module.with_custom_type2(
      definition.new("Animal") |> definition.with_publicity(True),
      animals,
    )

    use describer <- module.with_function(
      definition.new("describer") |> definition.with_publicity(True),
      function.new1(
        param1: parameter.new("animal", animal_type |> custom.to_type()),
        returns: type_.string,
        handler: fn(_thing) { expression.todo_(option.Some("implement me")) },
      ),
    )

    use _main <- module.with_function(
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() {
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
          expression.nil()
        }
      }),
    )

    module.eof()
  }

  let result =
    mod
    |> module.render(render.default_context())
    |> render.to_string()

  let expected =
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
  Nil
}"

  assert result == expected
}

pub fn module_case_on_custom_type_test() {
  let animals =
    custom.new(ExampleAnimal)
    |> custom.with_variant(fn(_) {
      variant.new("Dog")
      |> variant.with_argument(option.Some("bones"), type_.int)
    })
    |> custom.with_variant(fn(_) {
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), type_.string)
      |> variant.with_argument(option.Some("has_catnip"), type_.bool)
    })

  let mod = {
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use animal_type, dog_constructor, cat_constructor <- module.with_custom_type2(
      definition.new("Animal") |> definition.with_publicity(True),
      animals,
    )

    let int_to_string =
      import_.value_of_type(
        int_mod,
        "to_string",
        type_.reference(int.to_string),
      )

    use describer <- module.with_function(
      definition.new("describer") |> definition.with_publicity(True),
      function.new1(
        param1: parameter.new("animal", animal_type |> custom.to_type()),
        returns: type_.string,
        handler: fn(animal) {
          case_.new(animal)
          |> case_.with_pattern(
            pattern.from_constructor1(
              dog_constructor,
              pattern.variable("bones"),
            ),
            fn(bones) {
              expression.string("Dog with ")
              |> expression.concat_string(expression.call1(int_to_string, bones))
            },
          )
          |> case_.with_pattern(
            pattern.from_constructor2(
              cat_constructor,
              pattern.variable("name"),
              pattern.bool_literal(True),
            ),
            fn(info) {
              let #(name, Nil) = info
              expression.string("Cat named ")
              |> expression.concat_string(name)
              |> expression.concat_string(expression.string(" (energetic!)"))
            },
          )
          |> case_.with_pattern(
            pattern.from_constructor2(
              cat_constructor,
              pattern.variable("name"),
              pattern.bool_literal(False),
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
      definition.new(name: "main")
        |> definition.with_publicity(True),
      function.new0(returns: type_.nil, handler: fn() {
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
          expression.nil()
        }
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
  Nil
}"

  assert result == expected
}

pub fn module_let_on_custom_type_test() {
  let animals =
    custom.new(ExampleAnimal)
    |> custom.with_variant(fn(_) {
      variant.new("Dog")
      |> variant.with_argument(option.Some("bones"), type_.int)
    })
    |> custom.with_variant(fn(_) {
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), type_.string)
      |> variant.with_argument(option.Some("has_catnip"), type_.bool)
    })

  let mod = {
    use int_mod <- module.with_import(import_.new(["gleam", "int"]))
    use _animal_type, dog_constructor, cat_constructor <- module.with_custom_type2(
      definition.new("Animal") |> definition.with_publicity(True),
      animals,
    )

    let int_to_string =
      import_.value_of_type(
        int_mod,
        "to_string",
        type_.reference(int.to_string),
      )

    use _describe <- module.with_function(
      definition.new("describer") |> definition.with_publicity(True),
      function.new0(returns: type_.string, handler: fn() {
        use bones <- block.with_matching_let_declaration(
          pattern.from_constructor1(dog_constructor, pattern.variable("bones")),
          expression.construct1(
            constructor.to_expression1(dog_constructor),
            expression.int(4),
          ),
          True,
        )

        use #(name, Nil) <- block.with_matching_let_declaration(
          pattern.from_constructor2(
            cat_constructor,
            pattern.as_(pattern.string_literal("jake"), "name"),
            pattern.bool_literal(True),
          ),
          expression.construct2(
            constructor.to_expression2(cat_constructor),
            expression.string("jake"),
            expression.bool(True),
          ),
          True,
        )
        expression.concat_string(
          expression.concat_string(
            name,
            expression.string(" knows a dog with this many bones: "),
          ),
          expression.call1(int_to_string, bones),
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

pub type Animal {
  Dog(bones: Int)
  Cat(name: String, has_catnip: Bool)
}

pub fn describer() -> String {
  let assert Dog(bones) = Dog(4)
  let assert Cat(\"jake\" as name, True) = Cat(\"jake\", True)
  name <> \" knows a dog with this many bones: \" <> int.to_string(bones)
}"

  assert result == expected
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
      definition.new(name: "MoreAwesomeResult")
        |> definition.with_publicity(True),
      more_awesome_result,
    )

    use _main <- module.with_function(
      definition.new(name: "generate") |> definition.with_publicity(True),
      function.new0(
        returns: custom.to_type2(awesome_type, type_.int, type_.bool),
        handler: fn() {
          use _ <- block.with_let_declaration(
            "whoo",
            expression.call1(
              constructor.to_expression1(ok_awesome_constructor),
              expression.int(4),
            ),
          )
          expression.call2(
            constructor.to_expression2(less_ok_awesome_constructor),
            expression.int(23),
            expression.bool(True),
          )
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
    "pub type MoreAwesomeResult(awesome, not_awesome) {
  VeryOk(contents: awesome)
  NotVeryOk(contents: awesome, failures: not_awesome)
}

pub fn generate() -> MoreAwesomeResult(Int, Bool) {
  let whoo = VeryOk(4)
  NotVeryOk(23, True)
}"

  assert result == expected
}

pub fn module_with_custom_type_generics_multiple_ways_test() {
  let more_awesome_result: custom.CustomTypeBuilder(
    Nil,
    _,
    custom.Generics2(type_.GeneratedType(a), type_.GeneratedType(b)),
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
      definition.new(name: "MoreAwesomeResult")
        |> definition.with_publicity(True),
      more_awesome_result,
    )

    let first_ok_constructor: constructor.Constructor(
      Nil,
      _,
      custom.Generics2(type_.GeneratedType(Int), type_.GeneratedType(String)),
    ) = constructor.unsafe_convert(base_ok_constructor)

    let less_ok_constructor: constructor.Constructor(
      Nil,
      _,
      custom.Generics2(type_.GeneratedType(String), type_.GeneratedType(Bool)),
    ) = constructor.unsafe_convert(base_less_ok_constructor)

    use _main <- module.with_function(
      definition.new(name: "generate")
        |> definition.with_publicity(True),
      function.new0(
        returns: custom.to_type2(awesome_type, type_.string, type_.bool),
        handler: fn() {
          use _ <- block.with_let_declaration(
            "whoo",
            expression.call1(
              constructor.to_expression1(first_ok_constructor),
              expression.int(4),
            ),
          )
          expression.call2(
            constructor.to_expression2(less_ok_constructor),
            expression.string("hi"),
            expression.bool(True),
          )
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
    "pub type MoreAwesomeResult(awesome, not_awesome) {
  VeryOk(contents: awesome)
  NotVeryOk(contents: awesome, failures: not_awesome)
}

pub fn generate() -> MoreAwesomeResult(String, Bool) {
  let whoo = VeryOk(4)
  NotVeryOk(\"hi\", True)
}"

  assert result == expected
}

pub fn case_unchecked_variant_test() {
  let custom_variant =
    variant.new("CustomVariant")
    |> variant.with_arguments_dynamic(
      list.range(0, 10)
      |> list.map(fn(x) {
        #(
          option.Some("arg" <> int.to_string(x)),
          type_.int |> type_.to_dynamic(),
        )
      }),
    )
    |> variant.to_dynamic()

  let custom_type =
    custom.new(#())
    |> custom.with_dynamic_variants(fn(_) { [custom_variant] })

  let mod = {
    use int_module <- module.with_import(import_.new(["gleam", "int"]))

    use _, custom_constructors <- module.with_custom_type_dynamic(
      definition.new(name: "VariantHolder") |> definition.with_publicity(True),
      custom_type,
    )
    let assert [custom_variant, ..] = custom_constructors

    let match_on =
      expression.call_dynamic(
        constructor.to_expression_dynamic(custom_variant),
        list.range(0, 15)
          |> list.map(fn(x) { expression.int(x + 4) |> expression.to_dynamic() }),
      )

    use _ <- module.with_function(
      definition.new(name: "handle")
        |> definition.with_publicity(True),
      function.new0(returns: type_.int, handler: fn() {
        case_.new(match_on)
        |> case_.with_pattern(
          pattern.from_constructor_dynamic(
            custom_variant,
            list.range(0, 15)
              |> list.map(fn(x) {
                case x % 2 {
                  0 ->
                    pattern.int_literal(x + 4)
                    |> pattern.to_dynamic()
                  _ ->
                    pattern.variable("value" <> int.to_string(x))
                    |> pattern.to_dynamic()
                }
              }),
          ),
          fn(details) {
            expression.call1(
              import_.value_of_type(int_module, "sum", type_.reference(int.sum)),
              expression.list(details)
                |> expression.coerce_dynamic_unsafe(),
            )
          },
        )
        |> case_.with_pattern(pattern.variable("v"), fn(_) {
          // expression.concat_string(v, expression.string(" world"))
          expression.int(5)
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
}"

  assert result == expected
}

pub fn module_with_unchecked_custom_type__test() {
  let all_variants =
    list.range(0, 20)
    |> list.map(fn(i) {
      variant.new("Variant" <> int.to_string(i))
      |> variant.with_arguments_dynamic(
        list.range(0, i)
        |> list.reverse()
        |> list.rest()
        |> result.unwrap([])
        |> list.reverse()
        |> list.map(fn(x) {
          #(
            option.Some("arg" <> int.to_string(x)),
            type_.int |> type_.to_dynamic(),
          )
        }),
      )
      |> variant.to_dynamic()
    })

  let custom_type =
    custom.new(#())
    |> custom.with_dynamic_variants(fn(_) { all_variants })

  let mod = {
    use custom_type_type, custom_constructors <- module.with_custom_type_dynamic(
      definition.new(name: "VariantHolder")
        |> definition.with_publicity(True),
      custom_type,
    )

    let assert [variant0, _, _, variant3, ..] = custom_constructors

    use _get_variant <- module.with_function(
      definition.new(name: "get_variant")
        |> definition.with_publicity(True),
      function.new0(returns: custom.to_type(custom_type_type), handler: fn() {
        constructor.to_expression_dynamic(variant0)
      }),
    )
    use _get_other_variant <- module.with_function(
      definition.new(name: "get_other_variant")
        |> definition.with_publicity(True),
      function.new0(returns: custom.to_type(custom_type_type), handler: fn() {
        expression.call3(
          constructor.to_expression_dynamic(variant3),
          expression.int(1),
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
}"

  assert result == expected
}
