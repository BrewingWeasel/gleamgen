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
