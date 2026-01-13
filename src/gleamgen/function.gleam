import glam/doc
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleamgen/expression
import gleamgen/render
import gleamgen/types.{type Dynamic}

pub type Function(type_, ret) {
  Function(
    args: List(#(String, types.GeneratedType(Dynamic))),
    returns: types.GeneratedType(ret),
    body: expression.Expression(ret),
  )
}

pub fn new_raw(
  args args: List(#(String, types.GeneratedType(Dynamic))),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(List(expression.Expression(Dynamic))) ->
    expression.Expression(ret),
) -> Function(Dynamic, ret) {
  let body =
    handler(
      args
      |> list.map(fn(arg) { expression.raw(arg.0) }),
    )
  Function(args:, returns:, body:)
}

pub fn new0(
  returns returns: types.GeneratedType(ret),
  handler handler: fn() -> expression.Expression(ret),
) -> Function(fn(arg1) -> ret, ret) {
  let body = handler()
  Function(args: [], returns:, body:)
}

pub fn new1(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(expression.Expression(arg1)) -> expression.Expression(ret),
) -> Function(fn(arg1) -> ret, ret) {
  let body = handler(expression.raw(arg1.0))
  Function(args: [#(arg1.0, arg1.1 |> types.to_dynamic)], returns:, body:)
}

// rest of repetitve functions
// {{{

pub fn new2(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  arg2 arg2: #(String, types.GeneratedType(arg2)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(expression.Expression(arg1), expression.Expression(arg2)) ->
    expression.Expression(ret),
) -> Function(fn(arg1, arg2) -> ret, ret) {
  let body = handler(expression.raw(arg1.0), expression.raw(arg2.0))
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_dynamic),
      #(arg2.0, arg2.1 |> types.to_dynamic),
    ],
    returns:,
    body:,
  )
}

pub fn new3(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  arg2 arg2: #(String, types.GeneratedType(arg2)),
  arg3 arg3: #(String, types.GeneratedType(arg3)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(arg1),
    expression.Expression(arg2),
    expression.Expression(arg3),
  ) ->
    expression.Expression(ret),
) -> Function(fn(arg1, arg2, arg3) -> ret, ret) {
  let body =
    handler(
      expression.raw(arg1.0),
      expression.raw(arg2.0),
      expression.raw(arg3.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_dynamic),
      #(arg2.0, arg2.1 |> types.to_dynamic),
      #(arg3.0, arg3.1 |> types.to_dynamic),
    ],
    returns:,
    body:,
  )
}

pub fn new4(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  arg2 arg2: #(String, types.GeneratedType(arg2)),
  arg3 arg3: #(String, types.GeneratedType(arg3)),
  arg4 arg4: #(String, types.GeneratedType(arg4)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(arg1),
    expression.Expression(arg2),
    expression.Expression(arg3),
    expression.Expression(arg4),
  ) ->
    expression.Expression(ret),
) -> Function(fn(arg1, arg2, arg3, arg4) -> ret, ret) {
  let body =
    handler(
      expression.raw(arg1.0),
      expression.raw(arg2.0),
      expression.raw(arg3.0),
      expression.raw(arg4.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_dynamic),
      #(arg2.0, arg2.1 |> types.to_dynamic),
      #(arg3.0, arg3.1 |> types.to_dynamic),
      #(arg4.0, arg4.1 |> types.to_dynamic),
    ],
    returns:,
    body:,
  )
}

pub fn new5(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  arg2 arg2: #(String, types.GeneratedType(arg2)),
  arg3 arg3: #(String, types.GeneratedType(arg3)),
  arg4 arg4: #(String, types.GeneratedType(arg4)),
  arg5 arg5: #(String, types.GeneratedType(arg5)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(arg1),
    expression.Expression(arg2),
    expression.Expression(arg3),
    expression.Expression(arg4),
    expression.Expression(arg5),
  ) ->
    expression.Expression(ret),
) -> Function(fn(arg1, arg2, arg3, arg4, arg5) -> ret, ret) {
  let body =
    handler(
      expression.raw(arg1.0),
      expression.raw(arg2.0),
      expression.raw(arg3.0),
      expression.raw(arg4.0),
      expression.raw(arg5.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_dynamic),
      #(arg2.0, arg2.1 |> types.to_dynamic),
      #(arg3.0, arg3.1 |> types.to_dynamic),
      #(arg4.0, arg4.1 |> types.to_dynamic),
      #(arg5.0, arg5.1 |> types.to_dynamic),
    ],
    returns:,
    body:,
  )
}

pub fn new6(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  arg2 arg2: #(String, types.GeneratedType(arg2)),
  arg3 arg3: #(String, types.GeneratedType(arg3)),
  arg4 arg4: #(String, types.GeneratedType(arg4)),
  arg5 arg5: #(String, types.GeneratedType(arg5)),
  arg6 arg6: #(String, types.GeneratedType(arg6)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(arg1),
    expression.Expression(arg2),
    expression.Expression(arg3),
    expression.Expression(arg4),
    expression.Expression(arg5),
    expression.Expression(arg6),
  ) ->
    expression.Expression(ret),
) -> Function(fn(arg1, arg2, arg3, arg4, arg5, arg6) -> ret, ret) {
  let body =
    handler(
      expression.raw(arg1.0),
      expression.raw(arg2.0),
      expression.raw(arg3.0),
      expression.raw(arg4.0),
      expression.raw(arg5.0),
      expression.raw(arg6.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_dynamic),
      #(arg2.0, arg2.1 |> types.to_dynamic),
      #(arg3.0, arg3.1 |> types.to_dynamic),
      #(arg4.0, arg4.1 |> types.to_dynamic),
      #(arg5.0, arg5.1 |> types.to_dynamic),
      #(arg6.0, arg6.1 |> types.to_dynamic),
    ],
    returns:,
    body:,
  )
}

pub fn new7(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  arg2 arg2: #(String, types.GeneratedType(arg2)),
  arg3 arg3: #(String, types.GeneratedType(arg3)),
  arg4 arg4: #(String, types.GeneratedType(arg4)),
  arg5 arg5: #(String, types.GeneratedType(arg5)),
  arg6 arg6: #(String, types.GeneratedType(arg6)),
  arg7 arg7: #(String, types.GeneratedType(arg7)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(arg1),
    expression.Expression(arg2),
    expression.Expression(arg3),
    expression.Expression(arg4),
    expression.Expression(arg5),
    expression.Expression(arg6),
    expression.Expression(arg7),
  ) ->
    expression.Expression(ret),
) -> Function(fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7) -> ret, ret) {
  let body =
    handler(
      expression.raw(arg1.0),
      expression.raw(arg2.0),
      expression.raw(arg3.0),
      expression.raw(arg4.0),
      expression.raw(arg5.0),
      expression.raw(arg6.0),
      expression.raw(arg7.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_dynamic),
      #(arg2.0, arg2.1 |> types.to_dynamic),
      #(arg3.0, arg3.1 |> types.to_dynamic),
      #(arg4.0, arg4.1 |> types.to_dynamic),
      #(arg5.0, arg5.1 |> types.to_dynamic),
      #(arg6.0, arg6.1 |> types.to_dynamic),
      #(arg7.0, arg7.1 |> types.to_dynamic),
    ],
    returns:,
    body:,
  )
}

pub fn new8(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  arg2 arg2: #(String, types.GeneratedType(arg2)),
  arg3 arg3: #(String, types.GeneratedType(arg3)),
  arg4 arg4: #(String, types.GeneratedType(arg4)),
  arg5 arg5: #(String, types.GeneratedType(arg5)),
  arg6 arg6: #(String, types.GeneratedType(arg6)),
  arg7 arg7: #(String, types.GeneratedType(arg7)),
  arg8 arg8: #(String, types.GeneratedType(arg8)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(arg1),
    expression.Expression(arg2),
    expression.Expression(arg3),
    expression.Expression(arg4),
    expression.Expression(arg5),
    expression.Expression(arg6),
    expression.Expression(arg7),
    expression.Expression(arg8),
  ) ->
    expression.Expression(ret),
) -> Function(fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) -> ret, ret) {
  let body =
    handler(
      expression.raw(arg1.0),
      expression.raw(arg2.0),
      expression.raw(arg3.0),
      expression.raw(arg4.0),
      expression.raw(arg5.0),
      expression.raw(arg6.0),
      expression.raw(arg7.0),
      expression.raw(arg8.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_dynamic),
      #(arg2.0, arg2.1 |> types.to_dynamic),
      #(arg3.0, arg3.1 |> types.to_dynamic),
      #(arg4.0, arg4.1 |> types.to_dynamic),
      #(arg5.0, arg5.1 |> types.to_dynamic),
      #(arg6.0, arg6.1 |> types.to_dynamic),
      #(arg7.0, arg7.1 |> types.to_dynamic),
      #(arg8.0, arg8.1 |> types.to_dynamic),
    ],
    returns:,
    body:,
  )
}

pub fn new9(
  arg1 arg1: #(String, types.GeneratedType(arg1)),
  arg2 arg2: #(String, types.GeneratedType(arg2)),
  arg3 arg3: #(String, types.GeneratedType(arg3)),
  arg4 arg4: #(String, types.GeneratedType(arg4)),
  arg5 arg5: #(String, types.GeneratedType(arg5)),
  arg6 arg6: #(String, types.GeneratedType(arg6)),
  arg7 arg7: #(String, types.GeneratedType(arg7)),
  arg8 arg8: #(String, types.GeneratedType(arg8)),
  arg9 arg9: #(String, types.GeneratedType(arg9)),
  returns returns: types.GeneratedType(ret),
  handler handler: fn(
    expression.Expression(arg1),
    expression.Expression(arg2),
    expression.Expression(arg3),
    expression.Expression(arg4),
    expression.Expression(arg5),
    expression.Expression(arg6),
    expression.Expression(arg7),
    expression.Expression(arg8),
    expression.Expression(arg9),
  ) ->
    expression.Expression(ret),
) -> Function(
  fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) -> ret,
  ret,
) {
  let body =
    handler(
      expression.raw(arg1.0),
      expression.raw(arg2.0),
      expression.raw(arg3.0),
      expression.raw(arg4.0),
      expression.raw(arg5.0),
      expression.raw(arg6.0),
      expression.raw(arg7.0),
      expression.raw(arg8.0),
      expression.raw(arg9.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_dynamic),
      #(arg2.0, arg2.1 |> types.to_dynamic),
      #(arg3.0, arg3.1 |> types.to_dynamic),
      #(arg4.0, arg4.1 |> types.to_dynamic),
      #(arg5.0, arg5.1 |> types.to_dynamic),
      #(arg6.0, arg6.1 |> types.to_dynamic),
      #(arg7.0, arg7.1 |> types.to_dynamic),
      #(arg8.0, arg8.1 |> types.to_dynamic),
      #(arg9.0, arg9.1 |> types.to_dynamic),
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
    function.args
    |> list.map(pair.second)
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
  let rendered_args =
    func.args
    |> list.map(expression.render_attribute(_, context))
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
    rendered_args,
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
