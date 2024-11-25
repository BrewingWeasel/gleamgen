import gleam/int
import gleam/list
import gleam/option
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/module
import gleamgen/render
import gleamgen/types
import gleamgen/types/custom
import gleamgen/types/variant

type MyCustomTypeReference {
  MyCustomTypeReference
}

pub fn generate() {
  let generate_argument = fn(x) {
    let assert [type_, ..] =
      [
        types.int() |> types.to_unchecked(),
        types.string() |> types.to_unchecked(),
        types.bool() |> types.to_unchecked(),
      ]
      |> list.shuffle()
    #(option.Some("arg" <> int.to_string(x)), type_)
  }

  let generate_variant = fn(i) {
    let assert Ok(#(_, all_args)) =
      list.range(0, i)
      |> list.map(generate_argument)
      |> list.pop(fn(_) { True })

    variant.new("Variant" <> int.to_string(i))
    |> variant.with_arguments_unchecked(all_args)
    |> variant.to_unchecked()
  }

  let all_variants =
    list.range(0, 25)
    |> list.map(generate_variant)

  let custom_type =
    custom.new(MyCustomTypeReference)
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

    let assert [variant0, ..] = custom_constructors

    use _ <- module.with_function(
      module.DefinitionDetails("get_variant", is_public: True, attributes: []),
      function.new0(custom.to_type(custom_type_type), fn() {
        constructor.to_expression_unchecked(variant0)
      }),
    )
    module.eof()
  }
  mod |> module.render(render.default_context()) |> render.to_string()
}
