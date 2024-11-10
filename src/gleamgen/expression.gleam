import glam/doc
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleamgen/render
import gleamgen/types

pub opaque type Expression(type_) {
  Expression(
    internal: InternalExpression(type_),
    type_: types.GeneratedType(type_),
  )
}

type InternalExpression(type_) {
  IntLiteral(Int)
  FloatLiteral(Float)
  StrLiteral(String)
  BoolLiteral(Bool)
  ListLiteral(List(Expression(types.Unchecked)))
  Ident(String)
  Todo(Option(String))
  MathOperator(Expression(Int), MathOperator, Expression(Int))
  ConcatString(Expression(String), Expression(String))
  MathOperatorFloat(Expression(Float), MathOperator, Expression(Float))
  Call(Expression(types.Unchecked), List(Expression(types.Unchecked)))
  Block(List(Statement))
}

// ----------------------------------------------------------------------------
// Expression functions
// ----------------------------------------------------------------------------

pub fn int(value: Int) -> Expression(Int) {
  Expression(IntLiteral(value), types.int())
}

pub fn float(value: Float) -> Expression(Float) {
  Expression(FloatLiteral(value), types.float())
}

pub fn string(value: String) -> Expression(String) {
  Expression(StrLiteral(value), types.string())
}

pub fn bool(value: Bool) -> Expression(Bool) {
  Expression(BoolLiteral(value), types.bool())
}

pub fn list(value: List(Expression(t))) -> Expression(List(t)) {
  Expression(
    ListLiteral(value |> list.map(to_unchecked)),
    value
      |> list.first()
      |> result.map(type_)
      |> result.lazy_unwrap(fn() { types.unchecked() })
      |> types.list(),
  )
}

pub fn unchecked_ident(value: String) -> Expression(any) {
  Expression(Ident(value), types.unchecked())
}

/// Use the <> operator to concatenate two strings
/// ```gleam
/// expression.concat_string(expression.string("hello "), expression.string("world"))
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "\"hello \" <> \"world\""
/// ```
pub fn concat_string(
  expr1: Expression(String),
  expr2: Expression(String),
) -> Expression(String) {
  Expression(ConcatString(expr1, expr2), types.string())
}

/// Create a todo expression with an optional as clause
/// ```gleam
/// expression.todo_(option.Some("some unimplemented thing"))
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "todo as \"some unimplemented thing\""
/// ```
pub fn todo_(as_string: Option(String)) -> Expression(a) {
  Expression(Todo(as_string), types.unchecked())
}

/// See `math_operator` and `math_operator_float`
pub type MathOperator {
  Add
  Sub
  Mul
  Div
  GreaterThan
  GreaterThanOrEqual
  LessThan
  LessThanOrEqual
}

/// Apply a math operator to two expressions with the type of Int
/// ```gleam
/// expression.math_operator(expression.int(3), expression.Add, expression.int(5))
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "3 + 5"
/// ```
pub fn math_operator(
  expr1: Expression(Int),
  op: MathOperator,
  expr2: Expression(Int),
) -> Expression(Int) {
  Expression(MathOperator(expr1, op, expr2), types.int())
}

/// Apply a math operator to two expressions with the type of Float
/// ```gleam
/// expression.math_operator_float(
///   expression.float(3.3),
///   expression.GreaterThan,
///   expression.unchecked_ident("other_float")
/// )
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "3 >. other_float"
/// ```
pub fn math_operator_float(
  expr1: Expression(Float),
  op: MathOperator,
  expr2: Expression(Float),
) -> Expression(Int) {
  Expression(MathOperatorFloat(expr1, op, expr2), types.int())
}

pub fn call0(func: Expression(fn() -> ret)) -> Expression(ret) {
  Expression(internal: Call(func |> to_unchecked, []), type_: types.unchecked())
}

pub fn call1(
  func: Expression(fn(arg1) -> ret),
  arg1: Expression(arg1),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [arg1 |> to_unchecked]),
    type_: types.unchecked(),
  )
}

pub fn call2(
  func: Expression(fn(arg1, arg2) -> ret),
  arg1: Expression(arg1),
  arg2: Expression(arg2),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [
      arg1 |> to_unchecked,
      arg2 |> to_unchecked,
    ]),
    type_: types.unchecked(),
  )
}

pub fn call3(
  func: Expression(fn(arg1, arg2, arg3) -> ret),
  arg1: Expression(arg1),
  arg2: Expression(arg2),
  arg3: Expression(arg3),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [
      arg1 |> to_unchecked,
      arg2 |> to_unchecked,
      arg3 |> to_unchecked,
    ]),
    type_: types.unchecked(),
  )
}

pub fn call_unchecked(
  func: Expression(types.Unchecked),
  args: List(Expression(types.Unchecked)),
) -> Expression(types.Unchecked) {
  Expression(internal: Call(func, args), type_: types.unchecked())
}

@internal
pub fn new_block(expressions, return) -> Expression(type_) {
  Expression(internal: Block(expressions), type_: return)
}

/// Get the internal type of an expression
pub fn type_(expr: Expression(unchecked)) -> types.GeneratedType(unchecked) {
  expr.type_
}

// ----------------------------------------------------------------------------
// Expression type conversion functions
// ----------------------------------------------------------------------------

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_unchecked(type_: Expression(t)) -> Expression(types.Unchecked)

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn unsafe_from_unchecked(type_: Expression(t1)) -> Expression(t2)

// ----------------------------------------------------------------------------
// Statements
// ----------------------------------------------------------------------------

pub type Statement {
  LetDeclaration(String, Expression(types.Unchecked))
  ExpressionStatement(Expression(types.Unchecked))
}

// ----------------------------------------------------------------------------
// Rendering functions
// ----------------------------------------------------------------------------

pub fn render(
  expression: Expression(t),
  context: render.Context,
) -> render.Rendered {
  case expression.internal {
    IntLiteral(value) -> value |> int.to_string() |> doc.from_string()
    FloatLiteral(value) -> value |> float.to_string() |> doc.from_string()
    StrLiteral(value) ->
      doc.concat([
        doc.from_string("\""),
        doc.from_string(value),
        doc.from_string("\""),
      ])
    BoolLiteral(True) -> doc.from_string("True")
    BoolLiteral(False) -> doc.from_string("False")
    ListLiteral(values) -> render_list(values, context)
    Ident(value) -> doc.from_string(value)
    Todo(Some(value)) ->
      doc.concat([
        doc.from_string("todo as"),
        doc.space,
        doc.from_string("\""),
        doc.from_string(value),
        doc.from_string("\""),
      ])
      |> doc.group
    Todo(None) -> doc.from_string("todo")
    ConcatString(expr1, expr2) ->
      render_operator(expr1, expr2, doc.from_string("<>"), context)
    MathOperator(expr1, op, expr2) ->
      render_operator(
        expr1,
        expr2,
        case op {
          Add -> doc.from_string("+")
          Sub -> doc.from_string("-")
          Mul -> doc.from_string("*")
          Div -> doc.from_string("/")
          GreaterThan -> doc.from_string(">")
          GreaterThanOrEqual -> doc.from_string(">=")
          LessThan -> doc.from_string("<")
          LessThanOrEqual -> doc.from_string("<=")
        },
        context,
      )
    MathOperatorFloat(expr1, op, expr2) ->
      render_operator(
        expr1,
        expr2,
        case op {
          Add -> doc.from_string("+.")
          Sub -> doc.from_string("-.")
          Mul -> doc.from_string("*.")
          Div -> doc.from_string("/.")
          GreaterThan -> doc.from_string(">.")
          GreaterThanOrEqual -> doc.from_string(">=.")
          LessThan -> doc.from_string("<.")
          LessThanOrEqual -> doc.from_string("<=.")
        },
        context,
      )
    Call(func, args) -> render_call(func, args, context)
    Block(expressions) -> render_block(expressions, context)
  }
  |> render.Render
}

fn render_list(values, context) {
  let comma = doc.concat([doc.from_string(","), doc.space])
  let trailing_comma = doc.break("", ",")

  let open_paren = doc.concat([doc.from_string("["), doc.soft_break])
  let close_paren = doc.concat([trailing_comma, doc.from_string("]")])

  values
  |> list.map(fn(x) { render(x, context).doc })
  |> doc.join(with: comma)
  |> doc.prepend(open_paren)
  |> doc.nest(2)
  |> doc.append(close_paren)
  |> doc.group
}

pub fn render_statement(statement: Statement, context) -> render.Rendered {
  case statement {
    LetDeclaration(variable, value) ->
      doc.concat([
        doc.from_string("let "),
        doc.from_string(variable),
        doc.space,
        doc.from_string("="),
        doc.space,
        render(value, context).doc,
      ])
      |> render.Render
    ExpressionStatement(expr) -> render(expr, context)
  }
}

fn render_block(statements, context) {
  let inner =
    statements
    |> list.map(fn(statement) {
      render_statement(
        statement,
        render.Context(..context, include_brackets_current_level: True),
      ).doc
    })
    |> doc.join(doc.line)

  case context.include_brackets_current_level {
    True -> render.body(inner, force_newlines: True)
    False -> inner
  }
}

fn render_call(func, args, context) {
  doc.concat([
    render(func, context).doc,
    render.pretty_list(list.map(args, fn(arg) { render(arg, context).doc })),
  ])
}

fn render_operator(
  expr1: Expression(type_),
  expr2: Expression(type_),
  rendered_op: doc.Document,
  context: render.Context,
) {
  doc.concat([
    render(expr1, context).doc,
    doc.space,
    rendered_op,
    doc.space,
    render(expr2, context).doc,
  ])
}

@internal
pub fn render_attribute(
  x: #(String, types.GeneratedType(a)),
  context: render.Context,
) -> doc.Document {
  case context.render_types {
    True ->
      doc.concat([
        doc.from_string(x.0),
        case types.render_type(x.1) {
          Ok(rendered) ->
            doc.concat([doc.from_string(":"), doc.space, rendered.doc])
          Error(Nil) -> doc.empty
        },
      ])
    False -> doc.from_string(x.0)
  }
}
