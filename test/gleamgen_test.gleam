import gleam/int
import gleam/io
import gleam/option
import gleamgen/expression
import gleamgen/expression/block
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/import_
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
    "pub fn test_function() -> Int {
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
          name: "based_number",
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
    use language <- module.with_constant("language", expression.string("gleam"))

    use describer <- module.with_function(
      "describer",
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
      "main",
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

pub const language = \"gleam\"

pub fn describer(thing: String) -> String {
  \"The \" <> thing <> \" is written in \" <> language
}

pub fn main() -> Nil {
  io.println(describer(\"program\"))
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
      "main",
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
    |> custom.with_variant(
      variant.new("Dog")
      |> variant.with_argument(option.Some("bones"), types.int()),
    )
    |> custom.with_variant(
      variant.new("Cat")
      |> variant.with_argument(option.Some("name"), types.string())
      |> variant.with_argument(option.Some("has_catnip"), types.bool()),
    )

  let mod = {
    use animal_type, dog_constructor, cat_constructor <- module.with_custom_type2(
      "Animal",
      animals,
    )

    use describer <- module.with_function(
      "describer",
      function.new1(
        arg1: #("animal", animal_type),
        returns: types.string(),
        handler: fn(_thing) { expression.todo_(option.Some("implement me")) },
      ),
    )

    use _main <- module.with_function(
      "main",
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
