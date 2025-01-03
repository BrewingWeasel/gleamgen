import gleam/list
import gleam/result
import gleamgen/expression.{type Expression}
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
///
/// Blocks also can be created without the use syntax through `new` and `new_unchecked`
pub opaque type BlockBuilder(type_) {
  BlockBuilder(
    contents: List(expression.Statement),
    return: types.GeneratedType(type_),
  )
}

/// Used as the final expression in a block. If you want a dynamic final expression see `ending_unchecked`.
///
/// This will set the type of the block to the type of the expression passed in.
pub fn ending_block(expr: Expression(type_)) -> BlockBuilder(type_) {
  BlockBuilder(
    [expr |> expression.to_unchecked |> expression.ExpressionStatement],
    return: expression.type_(expr),
  )
}

pub fn ending_unchecked(
  statements: List(expression.Statement),
) -> BlockBuilder(type_) {
  BlockBuilder(
    statements,
    return: list.last(statements)
      |> result.map(fn(s) {
        case s {
          expression.ExpressionStatement(expr) ->
            expression.type_(expr) |> types.unsafe_from_unchecked()
          expression.LetDeclaration(_, _) -> types.unchecked()
        }
      })
      |> result.unwrap(types.unchecked()),
  )
}

pub fn new(
  statements: List(expression.Statement),
  return: types.GeneratedType(type_),
) -> expression.Expression(type_) {
  expression.new_block(statements, return)
}

pub fn new_unchecked(
  statements: List(expression.Statement),
) -> expression.Expression(any) {
  expression.new_block(statements, types.unchecked())
}

pub fn with_let_declaration(
  variable: String,
  value: Expression(type_),
  handler: fn(Expression(type_)) -> BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest = handler(expression.unchecked_ident(variable))
  BlockBuilder(
    ..rest,
    contents: [
      expression.LetDeclaration(variable, value |> expression.to_unchecked()),
      ..rest.contents
    ],
  )
}

pub fn with_statements_unchecked(
  statements: List(expression.Statement),
  handler: fn() -> BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest = handler()
  BlockBuilder(..rest, contents: list.append(statements, rest.contents))
}

pub fn with_expression(
  expression: Expression(type_),
  handler: fn() -> BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest = handler()
  BlockBuilder(
    ..rest,
    contents: [
      expression |> expression.to_unchecked |> expression.ExpressionStatement,
      ..rest.contents
    ],
  )
}

pub fn build(builder: BlockBuilder(ret)) -> Expression(ret) {
  expression.new_block(builder.contents, builder.return)
}

// Use expressions

pub type UseFunction(callback_args, ret) {
  UseFunction(
    function: Expression(types.Unchecked),
    args: List(Expression(types.Unchecked)),
  )
}

pub fn use_function1(
  func: Expression(fn(a, callback) -> ret),
  arg1: Expression(a),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_unchecked(func), [expression.to_unchecked(arg1)])
}

pub fn use_function2(
  func: Expression(fn(a, b, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_unchecked(func), [
    expression.to_unchecked(arg1),
    expression.to_unchecked(arg2),
  ])
}

pub fn use_function3(
  func: Expression(fn(a, b, c, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_unchecked(func), [
    expression.to_unchecked(arg1),
    expression.to_unchecked(arg2),
    expression.to_unchecked(arg3),
  ])
}

pub fn use_function4(
  func: Expression(fn(a, b, c, d, callback) -> ret),
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_unchecked(func), [
    expression.to_unchecked(arg1),
    expression.to_unchecked(arg2),
    expression.to_unchecked(arg3),
    expression.to_unchecked(arg4),
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
  UseFunction(expression.to_unchecked(func), [
    expression.to_unchecked(arg1),
    expression.to_unchecked(arg2),
    expression.to_unchecked(arg3),
    expression.to_unchecked(arg4),
    expression.to_unchecked(arg5),
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
  UseFunction(expression.to_unchecked(func), [
    expression.to_unchecked(arg1),
    expression.to_unchecked(arg2),
    expression.to_unchecked(arg3),
    expression.to_unchecked(arg4),
    expression.to_unchecked(arg5),
    expression.to_unchecked(arg6),
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
  UseFunction(expression.to_unchecked(func), [
    expression.to_unchecked(arg1),
    expression.to_unchecked(arg2),
    expression.to_unchecked(arg3),
    expression.to_unchecked(arg4),
    expression.to_unchecked(arg5),
    expression.to_unchecked(arg6),
    expression.to_unchecked(arg7),
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
  UseFunction(expression.to_unchecked(func), [
    expression.to_unchecked(arg1),
    expression.to_unchecked(arg2),
    expression.to_unchecked(arg3),
    expression.to_unchecked(arg4),
    expression.to_unchecked(arg5),
    expression.to_unchecked(arg6),
    expression.to_unchecked(arg7),
    expression.to_unchecked(arg8),
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
  UseFunction(expression.to_unchecked(func), [
    expression.to_unchecked(arg1),
    expression.to_unchecked(arg2),
    expression.to_unchecked(arg3),
    expression.to_unchecked(arg4),
    expression.to_unchecked(arg5),
    expression.to_unchecked(arg6),
    expression.to_unchecked(arg7),
    expression.to_unchecked(arg8),
    expression.to_unchecked(arg9),
  ])
}

pub fn use_function_unchecked(
  func: Expression(any),
  args: List(Expression(types.Unchecked)),
) -> UseFunction(callback, ret) {
  UseFunction(expression.to_unchecked(func), args)
}

pub fn with_use0(
  use_function: UseFunction(fn() -> ret, ret),
  callback: fn() -> BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest = callback()
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
  )
}

pub fn with_use1(
  use_function: UseFunction(fn(a) -> ret, ret),
  arg1: String,
  callback: fn(Expression(a)) -> BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest = callback(expression.unchecked_ident(arg1))
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [arg1])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
  )
}

pub fn with_use2(
  use_function: UseFunction(fn(a, b) -> ret, ret),
  arg1: String,
  arg2: String,
  callback: fn(Expression(a), Expression(b)) -> BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest =
    callback(expression.unchecked_ident(arg1), expression.unchecked_ident(arg2))
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [arg1, arg2])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
  )
}

pub fn with_use3(
  use_function: UseFunction(fn(a, b, c) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  callback: fn(Expression(a), Expression(b), Expression(c)) -> BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest =
    callback(
      expression.unchecked_ident(arg1),
      expression.unchecked_ident(arg2),
      expression.unchecked_ident(arg3),
    )
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
      ])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
  )
}

pub fn with_use4(
  use_function: UseFunction(fn(a, b, c, d) -> ret, ret),
  arg1: String,
  arg2: String,
  arg3: String,
  arg4: String,
  callback: fn(Expression(a), Expression(b), Expression(c), Expression(d)) ->
    BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest =
    callback(
      expression.unchecked_ident(arg1),
      expression.unchecked_ident(arg2),
      expression.unchecked_ident(arg3),
      expression.unchecked_ident(arg4),
    )
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
      ])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
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
    BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest =
    callback(
      expression.unchecked_ident(arg1),
      expression.unchecked_ident(arg2),
      expression.unchecked_ident(arg3),
      expression.unchecked_ident(arg4),
      expression.unchecked_ident(arg5),
    )
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
      ])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
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
    BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest =
    callback(
      expression.unchecked_ident(arg1),
      expression.unchecked_ident(arg2),
      expression.unchecked_ident(arg3),
      expression.unchecked_ident(arg4),
      expression.unchecked_ident(arg5),
      expression.unchecked_ident(arg6),
    )
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
      ])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
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
    BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest =
    callback(
      expression.unchecked_ident(arg1),
      expression.unchecked_ident(arg2),
      expression.unchecked_ident(arg3),
      expression.unchecked_ident(arg4),
      expression.unchecked_ident(arg5),
      expression.unchecked_ident(arg6),
      expression.unchecked_ident(arg7),
    )
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
      ])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
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
    BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest =
    callback(
      expression.unchecked_ident(arg1),
      expression.unchecked_ident(arg2),
      expression.unchecked_ident(arg3),
      expression.unchecked_ident(arg4),
      expression.unchecked_ident(arg5),
      expression.unchecked_ident(arg6),
      expression.unchecked_ident(arg7),
      expression.unchecked_ident(arg8),
    )
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, [
        arg1,
        arg2,
        arg3,
        arg4,
        arg5,
        arg6,
        arg7,
        arg8,
      ])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
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
    BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest =
    callback(
      expression.unchecked_ident(arg1),
      expression.unchecked_ident(arg2),
      expression.unchecked_ident(arg3),
      expression.unchecked_ident(arg4),
      expression.unchecked_ident(arg5),
      expression.unchecked_ident(arg6),
      expression.unchecked_ident(arg7),
      expression.unchecked_ident(arg8),
      expression.unchecked_ident(arg9),
    )
  BlockBuilder(
    ..rest,
    contents: [
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
      ])
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
  )
}

pub fn with_use_unchecked(
  use_function: UseFunction(any_func, ret),
  args: List(String),
  callback: fn(List(expression.Expression(types.Unchecked))) ->
    BlockBuilder(ret),
) -> BlockBuilder(ret) {
  let rest = callback(list.map(args, expression.unchecked_ident))
  BlockBuilder(
    ..rest,
    contents: [
      expression.new_use(use_function.function, use_function.args, args)
        |> expression.ExpressionStatement,
      ..rest.contents
    ],
  )
}
