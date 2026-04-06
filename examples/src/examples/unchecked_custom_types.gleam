import gleam/int
import gleam/list
import gleam/option
import gleamgen/expression/constructor
import gleamgen/function
import gleamgen/module
import gleamgen/module/definition
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
        types.int |> types.to_dynamic(),
        types.string |> types.to_dynamic(),
        types.bool |> types.to_dynamic(),
      ]
      |> list.shuffle()
    #(option.Some("arg" <> int.to_string(x)), type_)
  }

  let generate_variant = fn(i) {
    let all_args =
      int.range(0, i, [], fn(acc, i) { [generate_argument(i), ..acc] })
      |> list.reverse()

    variant.new("Variant" <> int.to_string(i))
    |> variant.with_arguments_dynamic(all_args)
    |> variant.to_dynamic()
  }

  let all_variants =
    int.range(0, 25, [], fn(acc, i) { [generate_variant(i), ..acc] })
    |> list.reverse()

  let custom_type =
    custom.new(MyCustomTypeReference)
    |> custom.with_dynamic_variants(fn(_) { all_variants })

  let mod = {
    use custom_type_type, custom_constructors <- module.with_custom_type_dynamic(
      definition.new("VariantHolder") |> definition.with_publicity(True),
      custom_type,
    )

    let assert [variant0, ..] = custom_constructors

    use _ <- module.with_function(
      definition.new("get_variant") |> definition.with_publicity(True),
      function.new0(custom.to_type(custom_type_type), fn() {
        constructor.to_expression_dynamic(variant0)
      }),
    )
    module.eof()
  }
  mod |> module.render(render.default_context()) |> render.to_string()
}
