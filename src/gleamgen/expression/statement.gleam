import gleamgen/expression
import gleamgen/types

pub type Statement =
  expression.Statement

pub fn expression(expr: expression.Expression(a)) -> Statement {
  expression.ExpressionStatement(expression.to_dynamic(expr))
}

pub fn dynamic_use(
  function: expression.Expression(types.Dynamic),
  arguments: List(expression.Expression(types.Dynamic)),
  callback_arguments: List(String),
) -> Statement {
  expression.ExpressionStatement(expression.new_use(
    function,
    arguments,
    callback_arguments,
  ))
}

pub fn dynamic_let(
  name: String,
  value: expression.Expression(types.Dynamic),
  assert_: Bool,
) -> Statement {
  expression.LetDeclaration(name:, value:, assert_:)
}
