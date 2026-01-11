import gleam/list
import gleamgen/expression.{type Expression}
import gleamgen/pattern
import gleamgen/render
import gleamgen/types

/// Blocks are used to group expressions together and are needed  to define local variables.
/// 
/// ```gleam 
/// {
///   use x <- block.with_let_declaration("x", expression.int(4))
///   use y <- block.with_let_declaration(
///     "y",
///     expression.math_operator(x, expression.Add, expression.int(5)),
///   )
///   block.ending_block(y)
/// }
/// |> block.build()
/// // type of Expression(Int)
/// |> expression.render(render.default_context())
///```
///
/// This will generate the following code:
/// ```gleam
/// {
///   let x = 4
///   let y = x + 5
///   y
/// }
///```
pub fn new(
  statements: List(expression.Statement),
  return: types.GeneratedType(type_),
) -> expression.Expression(type_) {
  expression.new_block(statements, return)
}

pub fn new_dynamic(
  statements: List(expression.Statement),
) -> expression.Expression(any) {
  expression.new_block(statements, types.dynamic())
}

pub fn with_let_declaration(
  variable: String,
  value: Expression(type_),
  handler: fn(Expression(type_)) -> Expression(ret),
) -> Expression(ret) {
  let rest = handler(expression.raw(variable))
  expression.add_to_or_create_block(
    expression.LetDeclaration(variable, value |> expression.to_dynamic(), False),
    rest,
  )
}

pub fn with_matching_let_declaration(
  pattern: pattern.Pattern(type_, output),
  value: Expression(type_),
  assert_ assert_: Bool,
  handler handler: fn(output) -> Expression(ret),
) -> Expression(ret) {
  let rest = handler(pattern.get_output(pattern))
  expression.add_to_or_create_block(
    expression.LetDeclaration(
      pattern
        |> pattern.to_dynamic()
        |> pattern.render(1)
        |> render.to_string(),
      value |> expression.to_dynamic(),
      assert_,
    ),
    rest,
  )
}

pub fn with_expression(
  expression: Expression(type_),
  handler: fn() -> Expression(ret),
) -> Expression(ret) {
  let rest = handler()
  expression.add_to_or_create_block(
    expression |> expression.to_dynamic |> expression.ExpressionStatement,
    rest,
  )
}

pub fn with_statements(
  statements: List(expression.Statement),
  handler: fn() -> Expression(ret),
) -> Expression(ret) {
  let rest = handler()
  expression.add_statements_to_or_create_block(statements, rest)
}

// Use expressions

pub type UseFunction(callback_args, ret) {
  UseFunction(
    function: Expression(types.Dynamic),
    args: List(Expression(types.Dynamic)),
  )
}

pub fn use_function1(
  func: Expression(fn(a, callback) -> ret),
  arg1: Expression(a),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [expression.to_dynamic(arg1)])
}

pub fn use_function2(
  func: Expression(fn(a, b, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [
    expression.to_dynamic(arg1),
    expression.to_dynamic(arg2),
  ])
}

pub fn use_function3(
  func: Expression(fn(a, b, c, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [
    expression.to_dynamic(arg1),
    expression.to_dynamic(arg2),
    expression.to_dynamic(arg3),
  ])
}

pub fn use_function4(
  func: Expression(fn(a, b, c, d, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [
    expression.to_dynamic(arg1),
    expression.to_dynamic(arg2),
    expression.to_dynamic(arg3),
    expression.to_dynamic(arg4),
  ])
}

pub fn use_function5(
  func: Expression(fn(a, b, c, d, e, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [
    expression.to_dynamic(arg1),
    expression.to_dynamic(arg2),
    expression.to_dynamic(arg3),
    expression.to_dynamic(arg4),
    expression.to_dynamic(arg5),
  ])
}

pub fn use_function6(
  func: Expression(fn(a, b, c, d, e, f, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
  arg6: Expression(f),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [
    expression.to_dynamic(arg1),
    expression.to_dynamic(arg2),
    expression.to_dynamic(arg3),
    expression.to_dynamic(arg4),
    expression.to_dynamic(arg5),
    expression.to_dynamic(arg6),
  ])
}

pub fn use_function7(
  func: Expression(fn(a, b, c, d, e, f, g, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
  arg6: Expression(f),
  arg7: Expression(g),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [
    expression.to_dynamic(arg1),
    expression.to_dynamic(arg2),
    expression.to_dynamic(arg3),
    expression.to_dynamic(arg4),
    expression.to_dynamic(arg5),
    expression.to_dynamic(arg6),
    expression.to_dynamic(arg7),
  ])
}

pub fn use_function8(
  func: Expression(fn(a, b, c, d, e, f, g, h, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
  arg6: Expression(f),
  arg7: Expression(g),
  arg8: Expression(h),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [
    expression.to_dynamic(arg1),
    expression.to_dynamic(arg2),
    expression.to_dynamic(arg3),
    expression.to_dynamic(arg4),
    expression.to_dynamic(arg5),
    expression.to_dynamic(arg6),
    expression.to_dynamic(arg7),
    expression.to_dynamic(arg8),
  ])
}

pub fn use_function9(
  func: Expression(fn(a, b, c, d, e, f, g, h, i, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
  arg6: Expression(f),
  arg7: Expression(g),
  arg8: Expression(h),
  arg9: Expression(i),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), [
    expression.to_dynamic(arg1),
    expression.to_dynamic(arg2),
    expression.to_dynamic(arg3),
    expression.to_dynamic(arg4),
    expression.to_dynamic(arg5),
    expression.to_dynamic(arg6),
    expression.to_dynamic(arg7),
    expression.to_dynamic(arg8),
    expression.to_dynamic(arg9),
  ])
}

pub fn use_function_dynamic(
  func: Expression(any),
  args: List(Expression(types.Dynamic)),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_dynamic(func), args)
}

pub fn with_use0(
  use_function: UseFunction(fn() -> ret, ret),
  callback: fn() -> Expression(ret),
) -> Expression(ret) {
  let rest = callback()
  expression.add_to_or_create_block(
    expression.new_use(use_function.function, use_function.args, [])
      |> expression.ExpressionStatement,
    rest,
  )
}

pub fn with_use1(
  use_function: UseFunction(fn(a) -> ret, ret),
  arg1: String,
  callback: fn(Expression(a)) -> Expression(ret),
) -> Expression(ret) {
  let rest = callback(expression.raw(arg1))
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [arg1]),
    ),
    rest,
  )
}

pub fn with_use2(
  use_function: UseFunction(fn(a, b) -> ret, ret),
  arg1: String,
  arg2: String,
  callback: fn(Expression(a), Expression(b)) -> Expression(ret),
) -> Expression(ret) {
  let rest = callback(expression.raw(arg1), expression.raw(arg2))
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [arg1, arg2]),
    ),
    rest,
  )
}

pub fn with_use3(
  use_function: UseFunction(fn(a, b, c) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  callback: fn(Expression(a), Expression(b), Expression(c)) -> Expression(ret),
) -> Expression(ret) {
  let rest =
    callback(expression.raw(arg1), expression.raw(arg2), expression.raw(arg3))
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
      ]),
    ),
    rest,
  )
}

pub fn with_use4(
  use_function: UseFunction(fn(a, b, c, d) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  arg4: String,
  callback: fn(Expression(a), Expression(b), Expression(c), Expression(d)) ->
    Expression(ret),
) -> Expression(ret) {
  let rest =
    callback(
      expression.raw(arg1),
      expression.raw(arg2),
      expression.raw(arg3),
      expression.raw(arg4),
    )
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
      ]),
    ),
    rest,
  )
}

pub fn with_use5(
  use_function: UseFunction(fn(a, b, c, d, e) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  arg4: String,
  arg5: String,
  callback: fn(
    Expression(a),
    Expression(b),
    Expression(c),
    Expression(d),
    Expression(e),
  ) ->
    Expression(ret),
) -> Expression(ret) {
  let rest =
    callback(
      expression.raw(arg1),
      expression.raw(arg2),
      expression.raw(arg3),
      expression.raw(arg4),
      expression.raw(arg5),
    )
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
      ]),
    ),
    rest,
  )
}

pub fn with_use6(
  use_function: UseFunction(fn(a, b, c, d, e, f) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  arg4: String,
  arg5: String,
  arg6: String,
  callback: fn(
    Expression(a),
    Expression(b),
    Expression(c),
    Expression(d),
    Expression(e),
    Expression(f),
  ) ->
    Expression(ret),
) -> Expression(ret) {
  let rest =
    callback(
      expression.raw(arg1),
      expression.raw(arg2),
      expression.raw(arg3),
      expression.raw(arg4),
      expression.raw(arg5),
      expression.raw(arg6),
    )
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
      ]),
    ),
    rest,
  )
}

pub fn with_use7(
  use_function: UseFunction(fn(a, b, c, d, e, f, g) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  arg4: String,
  arg5: String,
  arg6: String,
  arg7: String,
  callback: fn(
    Expression(a),
    Expression(b),
    Expression(c),
    Expression(d),
    Expression(e),
    Expression(f),
    Expression(g),
  ) ->
    Expression(ret),
) -> Expression(ret) {
  let rest =
    callback(
      expression.raw(arg1),
      expression.raw(arg2),
      expression.raw(arg3),
      expression.raw(arg4),
      expression.raw(arg5),
      expression.raw(arg6),
      expression.raw(arg7),
    )
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
      ]),
    ),
    rest,
  )
}

pub fn with_use8(
  use_function: UseFunction(fn(a, b, c, d, e, f, g, h) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  arg4: String,
  arg5: String,
  arg6: String,
  arg7: String,
  arg8: String,
  callback: fn(
    Expression(a),
    Expression(b),
    Expression(c),
    Expression(d),
    Expression(e),
    Expression(f),
    Expression(g),
    Expression(h),
  ) ->
    Expression(ret),
) -> Expression(ret) {
  let rest =
    callback(
      expression.raw(arg1),
      expression.raw(arg2),
      expression.raw(arg3),
      expression.raw(arg4),
      expression.raw(arg5),
      expression.raw(arg6),
      expression.raw(arg7),
      expression.raw(arg8),
    )
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
        arg8,
      ]),
    ),
    rest,
  )
}

pub fn with_use9(
  use_function: UseFunction(fn(a, b, c, d, e, f, g, h, i) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  arg4: String,
  arg5: String,
  arg6: String,
  arg7: String,
  arg8: String,
  arg9: String,
  callback: fn(
    Expression(a),
    Expression(b),
    Expression(c),
    Expression(d),
    Expression(e),
    Expression(f),
    Expression(g),
    Expression(h),
    Expression(i),
  ) ->
    Expression(ret),
) -> Expression(ret) {
  let rest =
    callback(
      expression.raw(arg1),
      expression.raw(arg2),
      expression.raw(arg3),
      expression.raw(arg4),
      expression.raw(arg5),
      expression.raw(arg6),
      expression.raw(arg7),
      expression.raw(arg8),
      expression.raw(arg9),
    )
  expression.add_to_or_create_block(
    expression.ExpressionStatement(
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
        arg8,
        arg9,
      ]),
    ),
    rest,
  )
}

pub fn with_use_dynamic(
  use_function: UseFunction(any_func, ret),
  args: List(String),
  callback: fn(List(Expression(types.Dynamic))) -> Expression(ret),
) -> Expression(ret) {
  let rest = callback(list.map(args, expression.raw))
  expression.add_to_or_create_block(
    expression.new_use(use_function.function, use_function.args, args)
      |> expression.ExpressionStatement,
    rest,
  )
}
