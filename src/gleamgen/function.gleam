import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleamgen/expression
import gleamgen/internal/render
import gleamgen/parameter.{type Parameter}
import gleamgen/types.{type Dynamic}

pub type Function(type_, ret) {
  Function(
    parameters: List(Parameter(Dynamic)),
    returns: types.GeneratedType(ret),
    body: expression.Expression(ret),
  )
}

pub fn new_raw(
  parameters parameters: List(Parameter(Dynamic)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(List(expression.Expression(Dynamic))) ->
    expression.Expression(ret),
) -> Function(Dynamic, ret) {
  let body =
    handler(
      parameters
      |> list.map(fn(param) { expression.raw(parameter.name(param)) }),
    )
  Function(parameters, returns:, body:)
}

pub fn new0(
  returns returns: types.GeneratedType(ret),
  handler handler: fn() -> expression.Expression(ret),
) -> Function(fn(arg1) -> ret, ret) {
  let body = handler()
  Function(parameters: [], returns:, body:)
}

pub fn new1(
  param1 param1: Parameter(param1),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(expression.Expression(param1)) ->
    expression.Expression(ret),
) -> Function(fn(param1) -> ret, ret) {
  let body = handler(expression.raw(parameter.name(param1)))
  Function(parameters: [parameter.to_dynamic(param1)], returns:, body:)
}

// rest of repetitve functions
// {{{

pub fn new2(
  param1 param1: Parameter(param1),
  param2 param2: Parameter(param2),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(param1),
    expression.Expression(param2),
  ) ->
    expression.Expression(ret),
) -> Function(fn(param1, param2) -> ret, ret) {
  let body =
    handler(
      expression.raw(parameter.name(param1)),
      expression.raw(parameter.name(param2)),
    )
  Function(
    parameters: [
      parameter.to_dynamic(param1),
      parameter.to_dynamic(param2),
    ],
    returns:,
    body:,
  )
}

pub fn new3(
  param1 param1: Parameter(param1),
  param2 param2: Parameter(param2),
  param3 param3: Parameter(param3),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(param1),
    expression.Expression(param2),
    expression.Expression(param3),
  ) ->
    expression.Expression(ret),
) -> Function(fn(param1, param2, param3) -> ret, ret) {
  let body =
    handler(
      expression.raw(parameter.name(param1)),
      expression.raw(parameter.name(param2)),
      expression.raw(parameter.name(param3)),
    )
  Function(
    parameters: [
      parameter.to_dynamic(param1),
      parameter.to_dynamic(param2),
      parameter.to_dynamic(param3),
    ],
    returns:,
    body:,
  )
}

pub fn new4(
  param1 param1: Parameter(param1),
  param2 param2: Parameter(param2),
  param3 param3: Parameter(param3),
  param4 param4: Parameter(param4),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(param1),
    expression.Expression(param2),
    expression.Expression(param3),
    expression.Expression(param4),
  ) ->
    expression.Expression(ret),
) -> Function(fn(param1, param2, param3, param4) -> ret, ret) {
  let body =
    handler(
      expression.raw(parameter.name(param1)),
      expression.raw(parameter.name(param2)),
      expression.raw(parameter.name(param3)),
      expression.raw(parameter.name(param4)),
    )
  Function(
    parameters: [
      parameter.to_dynamic(param1),
      parameter.to_dynamic(param2),
      parameter.to_dynamic(param3),
      parameter.to_dynamic(param4),
    ],
    returns:,
    body:,
  )
}

pub fn new5(
  param1 param1: Parameter(param1),
  param2 param2: Parameter(param2),
  param3 param3: Parameter(param3),
  param4 param4: Parameter(param4),
  param5 param5: Parameter(param5),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(param1),
    expression.Expression(param2),
    expression.Expression(param3),
    expression.Expression(param4),
    expression.Expression(param5),
  ) ->
    expression.Expression(ret),
) -> Function(fn(param1, param2, param3, param4, param5) -> ret, ret) {
  let body =
    handler(
      expression.raw(parameter.name(param1)),
      expression.raw(parameter.name(param2)),
      expression.raw(parameter.name(param3)),
      expression.raw(parameter.name(param4)),
      expression.raw(parameter.name(param5)),
    )
  Function(
    parameters: [
      parameter.to_dynamic(param1),
      parameter.to_dynamic(param2),
      parameter.to_dynamic(param3),
      parameter.to_dynamic(param4),
      parameter.to_dynamic(param5),
    ],
    returns:,
    body:,
  )
}

pub fn new6(
  param1 param1: Parameter(param1),
  param2 param2: Parameter(param2),
  param3 param3: Parameter(param3),
  param4 param4: Parameter(param4),
  param5 param5: Parameter(param5),
  param6 param6: Parameter(param6),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(param1),
    expression.Expression(param2),
    expression.Expression(param3),
    expression.Expression(param4),
    expression.Expression(param5),
    expression.Expression(param6),
  ) ->
    expression.Expression(ret),
) -> Function(fn(param1, param2, param3, param4, param5, param6) -> ret, ret) {
  let body =
    handler(
      expression.raw(parameter.name(param1)),
      expression.raw(parameter.name(param2)),
      expression.raw(parameter.name(param3)),
      expression.raw(parameter.name(param4)),
      expression.raw(parameter.name(param5)),
      expression.raw(parameter.name(param6)),
    )
  Function(
    parameters: [
      parameter.to_dynamic(param1),
      parameter.to_dynamic(param2),
      parameter.to_dynamic(param3),
      parameter.to_dynamic(param4),
      parameter.to_dynamic(param5),
      parameter.to_dynamic(param6),
    ],
    returns:,
    body:,
  )
}

pub fn new7(
  param1 param1: Parameter(param1),
  param2 param2: Parameter(param2),
  param3 param3: Parameter(param3),
  param4 param4: Parameter(param4),
  param5 param5: Parameter(param5),
  param6 param6: Parameter(param6),
  param7 param7: Parameter(param7),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(param1),
    expression.Expression(param2),
    expression.Expression(param3),
    expression.Expression(param4),
    expression.Expression(param5),
    expression.Expression(param6),
    expression.Expression(param7),
  ) ->
    expression.Expression(ret),
) -> Function(
  fn(param1, param2, param3, param4, param5, param6, param7) -> ret,
  ret,
) {
  let body =
    handler(
      expression.raw(parameter.name(param1)),
      expression.raw(parameter.name(param2)),
      expression.raw(parameter.name(param3)),
      expression.raw(parameter.name(param4)),
      expression.raw(parameter.name(param5)),
      expression.raw(parameter.name(param6)),
      expression.raw(parameter.name(param7)),
    )
  Function(
    parameters: [
      parameter.to_dynamic(param1),
      parameter.to_dynamic(param2),
      parameter.to_dynamic(param3),
      parameter.to_dynamic(param4),
      parameter.to_dynamic(param5),
      parameter.to_dynamic(param6),
      parameter.to_dynamic(param7),
    ],
    returns:,
    body:,
  )
}

pub fn new8(
  param1 param1: Parameter(param1),
  param2 param2: Parameter(param2),
  param3 param3: Parameter(param3),
  param4 param4: Parameter(param4),
  param5 param5: Parameter(param5),
  param6 param6: Parameter(param6),
  param7 param7: Parameter(param7),
  param8 param8: Parameter(param8),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(param1),
    expression.Expression(param2),
    expression.Expression(param3),
    expression.Expression(param4),
    expression.Expression(param5),
    expression.Expression(param6),
    expression.Expression(param7),
    expression.Expression(param8),
  ) ->
    expression.Expression(ret),
) -> Function(
  fn(param1, param2, param3, param4, param5, param6, param7, param8) -> ret,
  ret,
) {
  let body =
    handler(
      expression.raw(parameter.name(param1)),
      expression.raw(parameter.name(param2)),
      expression.raw(parameter.name(param3)),
      expression.raw(parameter.name(param4)),
      expression.raw(parameter.name(param5)),
      expression.raw(parameter.name(param6)),
      expression.raw(parameter.name(param7)),
      expression.raw(parameter.name(param8)),
    )
  Function(
    parameters: [
      parameter.to_dynamic(param1),
      parameter.to_dynamic(param2),
      parameter.to_dynamic(param3),
      parameter.to_dynamic(param4),
      parameter.to_dynamic(param5),
      parameter.to_dynamic(param6),
      parameter.to_dynamic(param7),
      parameter.to_dynamic(param8),
    ],
    returns:,
    body:,
  )
}

pub fn new9(
  param1 param1: Parameter(param1),
  param2 param2: Parameter(param2),
  param3 param3: Parameter(param3),
  param4 param4: Parameter(param4),
  param5 param5: Parameter(param5),
  param6 param6: Parameter(param6),
  param7 param7: Parameter(param7),
  param8 param8: Parameter(param8),
  param9 param9: Parameter(param9),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(param1),
    expression.Expression(param2),
    expression.Expression(param3),
    expression.Expression(param4),
    expression.Expression(param5),
    expression.Expression(param6),
    expression.Expression(param7),
    expression.Expression(param8),
    expression.Expression(param9),
  ) ->
    expression.Expression(ret),
) -> Function(
  fn(param1, param2, param3, param4, param5, param6, param7, param8, param9) ->
    ret,
  ret,
) {
  let body =
    handler(
      expression.raw(parameter.name(param1)),
      expression.raw(parameter.name(param2)),
      expression.raw(parameter.name(param3)),
      expression.raw(parameter.name(param4)),
      expression.raw(parameter.name(param5)),
      expression.raw(parameter.name(param6)),
      expression.raw(parameter.name(param7)),
      expression.raw(parameter.name(param8)),
      expression.raw(parameter.name(param9)),
    )
  Function(
    parameters: [
      parameter.to_dynamic(param1),
      parameter.to_dynamic(param2),
      parameter.to_dynamic(param3),
      parameter.to_dynamic(param4),
      parameter.to_dynamic(param5),
      parameter.to_dynamic(param6),
      parameter.to_dynamic(param7),
      parameter.to_dynamic(param8),
      parameter.to_dynamic(param9),
    ],
    returns:,
    body:,
  )
}

// }}}

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_dynamic(
  type_: Function(a, b),
) -> Function(types.Dynamic, types.Dynamic)

@external(erlang, "gleamgen_ffi", "get_function_name")
@external(javascript, "../gleamgen_ffi.mjs", "get_function_name")
@internal
pub fn get_function_name(type_: a) -> String

pub fn anonymous(function: Function(type_, ret)) -> expression.Expression(type_) {
  let type_ =
    function.parameters
    |> list.map(parameter.type_)
    |> types.dynamic_function(function.returns |> types.to_dynamic())
    |> types.coerce_dynamic_unsafe()

  let renderer = fn(context) { render(function, context, option.None) }

  expression.new_anonymous_function(renderer, type_)
}

pub fn render(
  func: Function(_, _),
  context: render.Context,
  name: option.Option(String),
) -> render.Rendered {
  let is_anonymous = option.is_none(name)

  let rendered_params =
    func.parameters
    |> list.map(parameter.render(_, include_labels: !is_anonymous, context:))
    |> render.pretty_list()

  let rendered_type = types.render_type(func.returns)
  let rendered_body =
    expression.render(
      func.body,
      render.Context(..context, include_brackets_current_level: False),
    )

  let #(rendered_name, force_newlines) = case name {
    option.Some(name) -> #(doc.from_string(" " <> name), True)
    option.None -> #(doc.empty, False)
  }

  doc.concat([
    doc.from_string("fn"),
    rendered_name,
    rendered_params,
    doc.space,
    case rendered_type {
      Ok(returned) ->
        doc.concat([doc.from_string("->"), doc.space, returned.doc, doc.space])
      Error(_) -> doc.empty
    },
    render.body(rendered_body.doc, force_newlines:),
  ])
  |> render.Render(details: render.merge_details(
    rendered_type
      |> result.map(fn(t) { t.details })
      |> result.unwrap(render.empty_details),
    rendered_body.details,
  ))
}
// vim: foldmethod=marker foldlevel=0
