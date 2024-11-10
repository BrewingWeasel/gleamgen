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

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_unchecked(
  type_: Function(a, b),
) -> Function(types.Unchecked, types.Unchecked)

@external(erlang, "gleamgen_ffi", "get_function_name")
@external(javascript, "../gleamgen_ffi.mjs", "get_function_name")
pub fn get_function_name(type_: a) -> String
