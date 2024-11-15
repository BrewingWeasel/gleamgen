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
  NilLiteral
  ListLiteral(List(Expression(types.Unchecked)))
  TupleLiteral(List(Expression(types.Unchecked)))
  Ident(String)
  Todo(Option(String))
  Panic(Option(String))
  MathOperator(Expression(Int), MathOperator, Expression(Int))
  ConcatString(Expression(String), Expression(String))
  MathOperatorFloat(Expression(Float), MathOperator, Expression(Float))
  Call(Expression(types.Unchecked), List(Expression(types.Unchecked)))
  Block(List(Statement))
  Case(Expression(types.Unchecked), List(doc.Document))
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

pub fn nil() -> Expression(Nil) {
  Expression(NilLiteral, types.nil())
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

pub fn tuple1(arg1: Expression(a)) -> Expression(#(a)) {
  Expression(TupleLiteral([arg1 |> to_unchecked()]), types.tuple1(type_(arg1)))
}

// Remaining repetitive tuple functions
// {{{

pub fn tuple2(arg1: Expression(a), arg2: Expression(b)) -> Expression(#(a, b)) {
  Expression(
    TupleLiteral([arg1 |> to_unchecked(), arg2 |> to_unchecked()]),
    types.tuple2(type_(arg1), type_(arg2)),
  )
}

pub fn tuple3(
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
) -> Expression(#(a, b, c)) {
  Expression(
    TupleLiteral([
      arg1 |> to_unchecked(),
      arg2 |> to_unchecked(),
      arg3 |> to_unchecked(),
    ]),
    types.tuple3(type_(arg1), type_(arg2), type_(arg3)),
  )
}

pub fn tuple4(
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
) -> Expression(#(a, b, c, d)) {
  Expression(
    TupleLiteral([
      arg1 |> to_unchecked(),
      arg2 |> to_unchecked(),
      arg3 |> to_unchecked(),
      arg4 |> to_unchecked(),
    ]),
    types.tuple4(type_(arg1), type_(arg2), type_(arg3), type_(arg4)),
  )
}

pub fn tuple5(
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
) -> Expression(#(a, b, c, d, e)) {
  Expression(
    TupleLiteral([
      arg1 |> to_unchecked(),
      arg2 |> to_unchecked(),
      arg3 |> to_unchecked(),
      arg4 |> to_unchecked(),
      arg5 |> to_unchecked(),
    ]),
    types.tuple5(
      type_(arg1),
      type_(arg2),
      type_(arg3),
      type_(arg4),
      type_(arg5),
    ),
  )
}

pub fn tuple6(
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
  arg6: Expression(f),
) -> Expression(#(a, b, c, d, e, f)) {
  Expression(
    TupleLiteral([
      arg1 |> to_unchecked(),
      arg2 |> to_unchecked(),
      arg3 |> to_unchecked(),
      arg4 |> to_unchecked(),
      arg5 |> to_unchecked(),
      arg6 |> to_unchecked(),
    ]),
    types.tuple6(
      type_(arg1),
      type_(arg2),
      type_(arg3),
      type_(arg4),
      type_(arg5),
      type_(arg6),
    ),
  )
}

pub fn tuple7(
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
  arg6: Expression(f),
  arg7: Expression(g),
) -> Expression(#(a, b, c, d, e, f, g)) {
  Expression(
    TupleLiteral([
      arg1 |> to_unchecked(),
      arg2 |> to_unchecked(),
      arg3 |> to_unchecked(),
      arg4 |> to_unchecked(),
      arg5 |> to_unchecked(),
      arg6 |> to_unchecked(),
      arg7 |> to_unchecked(),
    ]),
    types.tuple7(
      type_(arg1),
      type_(arg2),
      type_(arg3),
      type_(arg4),
      type_(arg5),
      type_(arg6),
      type_(arg7),
    ),
  )
}

pub fn tuple8(
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
  arg6: Expression(f),
  arg7: Expression(g),
  arg8: Expression(h),
) -> Expression(#(a, b, c, d, e, f, g, h)) {
  Expression(
    TupleLiteral([
      arg1 |> to_unchecked(),
      arg2 |> to_unchecked(),
      arg3 |> to_unchecked(),
      arg4 |> to_unchecked(),
      arg5 |> to_unchecked(),
      arg6 |> to_unchecked(),
      arg7 |> to_unchecked(),
      arg8 |> to_unchecked(),
    ]),
    types.tuple8(
      type_(arg1),
      type_(arg2),
      type_(arg3),
      type_(arg4),
      type_(arg5),
      type_(arg6),
      type_(arg7),
      type_(arg8),
    ),
  )
}

pub fn tuple9(
  arg1: Expression(a),
  arg2: Expression(b),
  arg3: Expression(c),
  arg4: Expression(d),
  arg5: Expression(e),
  arg6: Expression(f),
  arg7: Expression(g),
  arg8: Expression(h),
  arg9: Expression(i),
) -> Expression(#(a, b, c, d, e, f, g, h, i)) {
  Expression(
    TupleLiteral([
      arg1 |> to_unchecked(),
      arg2 |> to_unchecked(),
      arg3 |> to_unchecked(),
      arg4 |> to_unchecked(),
      arg5 |> to_unchecked(),
      arg6 |> to_unchecked(),
      arg7 |> to_unchecked(),
      arg8 |> to_unchecked(),
      arg9 |> to_unchecked(),
    ]),
    types.tuple9(
      type_(arg1),
      type_(arg2),
      type_(arg3),
      type_(arg4),
      type_(arg5),
      type_(arg6),
      type_(arg7),
      type_(arg8),
      type_(arg9),
    ),
  )
}

// }}}

// TODO: undefined tuple

/// Provide an ident that could be of any type
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

/// Create a panic expression with an optional as clause
/// ```gleam
/// expression.todo_(option.Some("ahhhhhh!!!"))
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "panic as \"ahhhhhh!!!\""
/// ```
pub fn panic_(as_string: Option(String)) -> Expression(a) {
  Expression(Panic(as_string), types.unchecked())
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

/// Call a function or constructor with no arguments
/// ```gleam
/// expression.call0(
///   import_.function0(dict_module, dict.new)
/// )
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "dict.new()"
/// ```
pub fn call0(func: Expression(fn() -> ret)) -> Expression(ret) {
  Expression(internal: Call(func |> to_unchecked, []), type_: types.unchecked())
}

/// Call a function or constructor with one argument
/// See `call0`
pub fn call1(
  func: Expression(fn(arg1) -> ret),
  arg1: Expression(arg1),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [arg1 |> to_unchecked]),
    type_: types.unchecked(),
  )
}

// remaining repetitive call functions
// {{{

/// Call a function or constructor with two arguments
/// See `call0`
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

/// Call a function or constructor with three arguments
/// See `call0`
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

/// Call a function or constructor with four arguments
/// See `call0`
pub fn call4(
  func: Expression(fn(arg1, arg2, arg3, arg4) -> ret),
  arg1: Expression(arg1),
  arg2: Expression(arg2),
  arg3: Expression(arg3),
  arg4: Expression(arg4),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [
      arg1 |> to_unchecked,
      arg2 |> to_unchecked,
      arg3 |> to_unchecked,
      arg4 |> to_unchecked,
    ]),
    type_: types.unchecked(),
  )
}

/// Call a function or constructor with five arguments
/// See `call0`
pub fn call5(
  func: Expression(fn(arg1, arg2, arg3, arg4, arg5) -> ret),
  arg1: Expression(arg1),
  arg2: Expression(arg2),
  arg3: Expression(arg3),
  arg4: Expression(arg4),
  arg5: Expression(arg5),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [
      arg1 |> to_unchecked,
      arg2 |> to_unchecked,
      arg3 |> to_unchecked,
      arg4 |> to_unchecked,
      arg5 |> to_unchecked,
    ]),
    type_: types.unchecked(),
  )
}

/// Call a function or constructor with six arguments
/// See `call0`
pub fn call6(
  func: Expression(fn(arg1, arg2, arg3, arg4, arg5, arg6) -> ret),
  arg1: Expression(arg1),
  arg2: Expression(arg2),
  arg3: Expression(arg3),
  arg4: Expression(arg4),
  arg5: Expression(arg5),
  arg6: Expression(arg6),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [
      arg1 |> to_unchecked,
      arg2 |> to_unchecked,
      arg3 |> to_unchecked,
      arg4 |> to_unchecked,
      arg5 |> to_unchecked,
      arg6 |> to_unchecked,
    ]),
    type_: types.unchecked(),
  )
}

/// Call a function or constructor with seven arguments
/// See `call0`
pub fn call7(
  func: Expression(fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7) -> ret),
  arg1: Expression(arg1),
  arg2: Expression(arg2),
  arg3: Expression(arg3),
  arg4: Expression(arg4),
  arg5: Expression(arg5),
  arg6: Expression(arg6),
  arg7: Expression(arg7),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [
      arg1 |> to_unchecked,
      arg2 |> to_unchecked,
      arg3 |> to_unchecked,
      arg4 |> to_unchecked,
      arg5 |> to_unchecked,
      arg6 |> to_unchecked,
      arg7 |> to_unchecked,
    ]),
    type_: types.unchecked(),
  )
}

/// Call a function or constructor with eight arguments
/// See `call0`
pub fn call8(
  func: Expression(fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) -> ret),
  arg1: Expression(arg1),
  arg2: Expression(arg2),
  arg3: Expression(arg3),
  arg4: Expression(arg4),
  arg5: Expression(arg5),
  arg6: Expression(arg6),
  arg7: Expression(arg7),
  arg8: Expression(arg8),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [
      arg1 |> to_unchecked,
      arg2 |> to_unchecked,
      arg3 |> to_unchecked,
      arg4 |> to_unchecked,
      arg5 |> to_unchecked,
      arg6 |> to_unchecked,
      arg7 |> to_unchecked,
      arg8 |> to_unchecked,
    ]),
    type_: types.unchecked(),
  )
}

/// Call a function or constructor with nine arguments
/// See `call0`
pub fn call9(
  func: Expression(
    fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) -> ret,
  ),
  arg1: Expression(arg1),
  arg2: Expression(arg2),
  arg3: Expression(arg3),
  arg4: Expression(arg4),
  arg5: Expression(arg5),
  arg6: Expression(arg6),
  arg7: Expression(arg7),
  arg8: Expression(arg8),
  arg9: Expression(arg9),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_unchecked, [
      arg1 |> to_unchecked,
      arg2 |> to_unchecked,
      arg3 |> to_unchecked,
      arg4 |> to_unchecked,
      arg5 |> to_unchecked,
      arg6 |> to_unchecked,
      arg7 |> to_unchecked,
      arg8 |> to_unchecked,
      arg9 |> to_unchecked,
    ]),
    type_: types.unchecked(),
  )
}

// }}}

/// Call a function or constructor without type checking
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

@internal
pub fn new_case(to_match_on, matchers, return) -> Expression(type_) {
  Expression(internal: Case(to_match_on, matchers), type_: return)
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

/// Convert an expression to any type without checking
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
    NilLiteral -> doc.from_string("Nil")
    ListLiteral(values) -> render_list(values, context)
    TupleLiteral(values) -> render_tuple(values, context)
    Ident(value) -> doc.from_string(value)
    Todo(as_string) -> render_panicking_expression("todo", as_string)
    Panic(as_string) -> render_panicking_expression("panic", as_string)
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
    Case(to_match_on, matchers) -> render_case(to_match_on, matchers, context)
  }
  |> render.Render
}

fn render_panicking_expression(name: String, as_string: Option(String)) {
  case as_string {
    Some(value) ->
      doc.concat([
        doc.from_string(name <> " as"),
        doc.space,
        doc.from_string("\""),
        doc.from_string(value),
        doc.from_string("\""),
      ])
      |> doc.group
    None -> doc.from_string(name)
  }
}

fn render_case(to_match_on, matchers, context) {
  doc.concat([
    doc.from_string("case "),
    render(to_match_on, context).doc,
    doc.space,
    render.body(
      matchers
        |> doc.join(doc.line),
      force_newlines: True,
    ),
  ])
}

fn render_tuple(values, context) {
  values
  |> list.map(fn(x) { render(x, context).doc })
  |> render.pretty_list()
  |> doc.prepend(doc.from_string("#"))
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
// vim: foldmethod=marker foldlevel=0
