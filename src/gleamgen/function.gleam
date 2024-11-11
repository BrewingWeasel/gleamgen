import gleamgen/expression
import gleamgen/types.{type Unchecked}

pub type Function(type_, ret) {
  Function(
    args: List(#(String, types.GeneratedType(Unchecked))),
    returns: types.GeneratedType(ret),
    body: expression.Expression(ret),
  )
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
  let body = handler(expression.unchecked_ident(arg1.0))
  Function(args: [#(arg1.0, arg1.1 |> types.to_unchecked)], returns:, body:)
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
  let body =
    handler(
      expression.unchecked_ident(arg1.0),
      expression.unchecked_ident(arg2.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_unchecked),
      #(arg2.0, arg2.1 |> types.to_unchecked),
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
      expression.unchecked_ident(arg1.0),
      expression.unchecked_ident(arg2.0),
      expression.unchecked_ident(arg3.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_unchecked),
      #(arg2.0, arg2.1 |> types.to_unchecked),
      #(arg3.0, arg3.1 |> types.to_unchecked),
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
      expression.unchecked_ident(arg1.0),
      expression.unchecked_ident(arg2.0),
      expression.unchecked_ident(arg3.0),
      expression.unchecked_ident(arg4.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_unchecked),
      #(arg2.0, arg2.1 |> types.to_unchecked),
      #(arg3.0, arg3.1 |> types.to_unchecked),
      #(arg4.0, arg4.1 |> types.to_unchecked),
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
      expression.unchecked_ident(arg1.0),
      expression.unchecked_ident(arg2.0),
      expression.unchecked_ident(arg3.0),
      expression.unchecked_ident(arg4.0),
      expression.unchecked_ident(arg5.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_unchecked),
      #(arg2.0, arg2.1 |> types.to_unchecked),
      #(arg3.0, arg3.1 |> types.to_unchecked),
      #(arg4.0, arg4.1 |> types.to_unchecked),
      #(arg5.0, arg5.1 |> types.to_unchecked),
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
      expression.unchecked_ident(arg1.0),
      expression.unchecked_ident(arg2.0),
      expression.unchecked_ident(arg3.0),
      expression.unchecked_ident(arg4.0),
      expression.unchecked_ident(arg5.0),
      expression.unchecked_ident(arg6.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_unchecked),
      #(arg2.0, arg2.1 |> types.to_unchecked),
      #(arg3.0, arg3.1 |> types.to_unchecked),
      #(arg4.0, arg4.1 |> types.to_unchecked),
      #(arg5.0, arg5.1 |> types.to_unchecked),
      #(arg6.0, arg6.1 |> types.to_unchecked),
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
      expression.unchecked_ident(arg1.0),
      expression.unchecked_ident(arg2.0),
      expression.unchecked_ident(arg3.0),
      expression.unchecked_ident(arg4.0),
      expression.unchecked_ident(arg5.0),
      expression.unchecked_ident(arg6.0),
      expression.unchecked_ident(arg7.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_unchecked),
      #(arg2.0, arg2.1 |> types.to_unchecked),
      #(arg3.0, arg3.1 |> types.to_unchecked),
      #(arg4.0, arg4.1 |> types.to_unchecked),
      #(arg5.0, arg5.1 |> types.to_unchecked),
      #(arg6.0, arg6.1 |> types.to_unchecked),
      #(arg7.0, arg7.1 |> types.to_unchecked),
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
      expression.unchecked_ident(arg1.0),
      expression.unchecked_ident(arg2.0),
      expression.unchecked_ident(arg3.0),
      expression.unchecked_ident(arg4.0),
      expression.unchecked_ident(arg5.0),
      expression.unchecked_ident(arg6.0),
      expression.unchecked_ident(arg7.0),
      expression.unchecked_ident(arg8.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_unchecked),
      #(arg2.0, arg2.1 |> types.to_unchecked),
      #(arg3.0, arg3.1 |> types.to_unchecked),
      #(arg4.0, arg4.1 |> types.to_unchecked),
      #(arg5.0, arg5.1 |> types.to_unchecked),
      #(arg6.0, arg6.1 |> types.to_unchecked),
      #(arg7.0, arg7.1 |> types.to_unchecked),
      #(arg8.0, arg8.1 |> types.to_unchecked),
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
      expression.unchecked_ident(arg1.0),
      expression.unchecked_ident(arg2.0),
      expression.unchecked_ident(arg3.0),
      expression.unchecked_ident(arg4.0),
      expression.unchecked_ident(arg5.0),
      expression.unchecked_ident(arg6.0),
      expression.unchecked_ident(arg7.0),
      expression.unchecked_ident(arg8.0),
      expression.unchecked_ident(arg9.0),
    )
  Function(
    args: [
      #(arg1.0, arg1.1 |> types.to_unchecked),
      #(arg2.0, arg2.1 |> types.to_unchecked),
      #(arg3.0, arg3.1 |> types.to_unchecked),
      #(arg4.0, arg4.1 |> types.to_unchecked),
      #(arg5.0, arg5.1 |> types.to_unchecked),
      #(arg6.0, arg6.1 |> types.to_unchecked),
      #(arg7.0, arg7.1 |> types.to_unchecked),
      #(arg8.0, arg8.1 |> types.to_unchecked),
      #(arg9.0, arg9.1 |> types.to_unchecked),
    ],
    returns:,
    body:,
  )
}

// }}}

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_unchecked(
  type_: Function(a, b),
) -> Function(types.Unchecked, types.Unchecked)

@external(erlang, "gleamgen_ffi", "get_function_name")
@external(javascript, "../gleamgen_ffi.mjs", "get_function_name")
@internal
pub fn get_function_name(type_: a) -> String
// vim: foldmethod=marker foldlevel=0
