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
