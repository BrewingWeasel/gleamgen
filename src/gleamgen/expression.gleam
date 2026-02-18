import glam/doc
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleamgen/internal/render
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
  ListLiteral(
    prepending: List(Expression(types.Dynamic)),
    initial: Option(Expression(types.Dynamic)),
  )
  Equals(Expression(types.Dynamic), Expression(types.Dynamic))
  NotEquals(Expression(types.Dynamic), Expression(types.Dynamic))
  TupleLiteral(List(Expression(types.Dynamic)))
  Ident(String)
  RawDoc(doc.Document)
  Todo(Option(String))
  Panic(Option(String))
  Echo(expression: Expression(types.Dynamic), as_string: Option(String))
  Assert(condition: Expression(Bool), as_string: Option(String))
  MathOperator(Expression(Int), MathOperator, Expression(Int))
  MathOperatorFloat(Expression(Float), MathOperator, Expression(Float))
  Comparison(Expression(Int), Comparison, Expression(Int))
  ComparisonFloat(Expression(Float), Comparison, Expression(Float))
  ConcatString(Expression(String), Expression(String))
  Call(Expression(types.Dynamic), List(Expression(types.Dynamic)))
  SingleConstructor(Expression(types.Dynamic))
  Block(List(Statement))
  Case(
    Expression(types.Dynamic),
    List(fn(render.Context, Int) -> render.Rendered),
    Bool,
  )
  AnonymousFunction(fn(render.Context) -> render.Rendered)
  Use(
    function: Expression(types.Dynamic),
    args: List(Expression(types.Dynamic)),
    callback_args: List(String),
  )
}

// ----------------------------------------------------------------------------
// Expression functions
// ----------------------------------------------------------------------------

pub fn int(value: Int) -> Expression(Int) {
  Expression(IntLiteral(value), types.int)
}

pub fn float(value: Float) -> Expression(Float) {
  Expression(FloatLiteral(value), types.float)
}

pub fn string(value: String) -> Expression(String) {
  Expression(StrLiteral(value), types.string)
}

pub fn bool(value: Bool) -> Expression(Bool) {
  Expression(BoolLiteral(value), types.bool)
}

pub fn nil() -> Expression(Nil) {
  Expression(NilLiteral, types.nil)
}

pub fn list(value: List(Expression(t))) -> Expression(List(t)) {
  Expression(
    ListLiteral(value |> list.map(to_dynamic), None),
    value
      |> list.first()
      |> result.map(type_)
      |> result.lazy_unwrap(fn() { types.dynamic() })
      |> types.list(),
  )
}

pub fn list_prepend(
  prepending: List(Expression(t)),
  original: Expression(List(t)),
) -> Expression(List(t)) {
  Expression(
    ListLiteral(
      prepending: prepending |> list.map(to_dynamic),
      initial: Some(original |> to_dynamic()),
    ),
    prepending
      |> list.first()
      |> result.map(type_)
      |> result.map(types.list)
      |> result.unwrap(original.type_),
  )
}

pub fn tuple1(arg1: Expression(a)) -> Expression(#(a)) {
  Expression(TupleLiteral([arg1 |> to_dynamic()]), types.tuple1(type_(arg1)))
}

pub fn equals(first: Expression(a), second: Expression(a)) -> Expression(Bool) {
  Expression(Equals(first |> to_dynamic(), second |> to_dynamic()), types.bool)
}

pub fn not_equals(
  first: Expression(a),
  second: Expression(a),
) -> Expression(Bool) {
  Expression(
    NotEquals(first |> to_dynamic(), second |> to_dynamic()),
    types.bool,
  )
}

// Remaining repetitive tuple functions
// {{{

pub fn tuple2(arg1: Expression(a), arg2: Expression(b)) -> Expression(#(a, b)) {
  Expression(
    TupleLiteral([arg1 |> to_dynamic(), arg2 |> to_dynamic()]),
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
      arg1 |> to_dynamic(),
      arg2 |> to_dynamic(),
      arg3 |> to_dynamic(),
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
      arg1 |> to_dynamic(),
      arg2 |> to_dynamic(),
      arg3 |> to_dynamic(),
      arg4 |> to_dynamic(),
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
      arg1 |> to_dynamic(),
      arg2 |> to_dynamic(),
      arg3 |> to_dynamic(),
      arg4 |> to_dynamic(),
      arg5 |> to_dynamic(),
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
      arg1 |> to_dynamic(),
      arg2 |> to_dynamic(),
      arg3 |> to_dynamic(),
      arg4 |> to_dynamic(),
      arg5 |> to_dynamic(),
      arg6 |> to_dynamic(),
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
      arg1 |> to_dynamic(),
      arg2 |> to_dynamic(),
      arg3 |> to_dynamic(),
      arg4 |> to_dynamic(),
      arg5 |> to_dynamic(),
      arg6 |> to_dynamic(),
      arg7 |> to_dynamic(),
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
      arg1 |> to_dynamic(),
      arg2 |> to_dynamic(),
      arg3 |> to_dynamic(),
      arg4 |> to_dynamic(),
      arg5 |> to_dynamic(),
      arg6 |> to_dynamic(),
      arg7 |> to_dynamic(),
      arg8 |> to_dynamic(),
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
      arg1 |> to_dynamic(),
      arg2 |> to_dynamic(),
      arg3 |> to_dynamic(),
      arg4 |> to_dynamic(),
      arg5 |> to_dynamic(),
      arg6 |> to_dynamic(),
      arg7 |> to_dynamic(),
      arg8 |> to_dynamic(),
      arg9 |> to_dynamic(),
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
pub fn raw(value: String) -> Expression(a) {
  Expression(Ident(value), types.dynamic())
}

@internal
pub fn raw_doc(value: doc.Document) -> Expression(a) {
  Expression(RawDoc(value), types.dynamic())
}

/// Provide a string to inject without any checking of the specified type
pub fn raw_of_type(
  value: String,
  type_: types.GeneratedType(t),
) -> Expression(t) {
  Expression(Ident(value), type_)
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
  Expression(ConcatString(expr1, expr2), types.string)
}

/// Create a todo expression with an optional as clause
/// ```gleam
/// expression.todo_(option.Some("some unimplemented thing"))
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "todo as \"some unimplemented thing\""
/// ```
pub fn todo_(as_string: Option(String)) -> Expression(a) {
  Expression(Todo(as_string), types.dynamic())
}

/// Create a panic expression with an optional as clause
/// ```gleam
/// expression.todo_(option.Some("ahhhhhh!!!"))
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "panic as \"ahhhhhh!!!\""
/// ```
pub fn panic_(as_string: Option(String)) -> Expression(a) {
  Expression(Panic(as_string), types.dynamic())
}

/// Create an assert expression with an optional as clause
pub fn assert_(
  condition: Expression(Bool),
  as_string: Option(String),
) -> Expression(Nil) {
  Expression(Assert(condition, as_string), types.nil)
}

pub fn echo_(
  expression: Expression(a),
  as_string: Option(String),
) -> Expression(a) {
  Expression(Echo(to_dynamic(expression), as_string), expression.type_)
}

pub fn ok(ok_value: Expression(ok)) -> Expression(Result(ok, err)) {
  Expression(
    internal: Call(raw("Ok"), [ok_value |> to_dynamic]),
    type_: types.result(type_(ok_value), types.dynamic()),
  )
}

pub fn error(err_value: Expression(err)) -> Expression(Result(ok, err)) {
  Expression(
    internal: Call(raw("Error"), [err_value |> to_dynamic]),
    type_: types.result(types.dynamic(), type_(err_value)),
  )
}

/// See `math_operator` and `math_operator_float`
pub type MathOperator {
  Add
  Sub
  Mul
  Div
}

pub type Comparison {
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
  Expression(MathOperator(expr1, op, expr2), types.int)
}

/// Apply a math operator to two expressions with the type of Float
/// ```gleam
/// expression.math_operator_float(
///   expression.float(3.3),
///   expression.Sub,
///   expression.unchecked_ident("other_float")
/// )
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "3.3 -. other_float"
/// ```
pub fn math_operator_float(
  expr1: Expression(Float),
  op: MathOperator,
  expr2: Expression(Float),
) -> Expression(Int) {
  Expression(MathOperatorFloat(expr1, op, expr2), types.int)
}

pub fn comparison(
  expr1: Expression(Int),
  operator: Comparison,
  expr2: Expression(Int),
) -> Expression(Bool) {
  Expression(Comparison(expr1, operator, expr2), types.bool)
}

pub fn comparison_float(
  expr1: Expression(Float),
  operator: Comparison,
  expr2: Expression(Float),
) -> Expression(Bool) {
  Expression(ComparisonFloat(expr1, operator, expr2), types.bool)
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
  Expression(internal: Call(func |> to_dynamic, []), type_: types.dynamic())
}

/// Call a function or constructor with one argument
/// See `call0`
pub fn call1(
  func: Expression(fn(arg1) -> ret),
  arg1: Expression(arg1),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_dynamic, [arg1 |> to_dynamic]),
    type_: types.dynamic(),
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
    internal: Call(func |> to_dynamic, [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
    ]),
    type_: types.dynamic(),
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
    internal: Call(func |> to_dynamic, [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
    ]),
    type_: types.dynamic(),
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
    internal: Call(func |> to_dynamic, [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
    ]),
    type_: types.dynamic(),
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
    internal: Call(func |> to_dynamic, [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
    ]),
    type_: types.dynamic(),
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
    internal: Call(func |> to_dynamic, [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
      arg6 |> to_dynamic,
    ]),
    type_: types.dynamic(),
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
    internal: Call(func |> to_dynamic, [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
      arg6 |> to_dynamic,
      arg7 |> to_dynamic,
    ]),
    type_: types.dynamic(),
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
    internal: Call(func |> to_dynamic, [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
      arg6 |> to_dynamic,
      arg7 |> to_dynamic,
      arg8 |> to_dynamic,
    ]),
    type_: types.dynamic(),
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
    internal: Call(func |> to_dynamic, [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
      arg6 |> to_dynamic,
      arg7 |> to_dynamic,
      arg8 |> to_dynamic,
      arg9 |> to_dynamic,
    ]),
    type_: types.dynamic(),
  )
}

// }}}

/// Call a function or constructor without type checking
pub fn call_dynamic(
  func: Expression(types.Dynamic),
  args: List(Expression(types.Dynamic)),
) -> Expression(types.Dynamic) {
  Expression(internal: Call(func, args), type_: types.dynamic())
}

pub fn construct0(constructor: Expression(fn() -> ret)) -> Expression(ret) {
  Expression(
    internal: SingleConstructor(constructor |> to_dynamic),
    type_: types.dynamic(),
  )
}

pub const construct1 = call1

pub const construct2 = call2

pub const construct3 = call3

pub const construct4 = call4

pub const construct5 = call5

pub const construct6 = call6

pub const construct7 = call7

pub const construct8 = call8

pub const construct9 = call9

@internal
pub fn new_block(expressions, return) -> Expression(type_) {
  Expression(internal: Block(expressions), type_: return)
}

@internal
pub fn add_to_or_create_block(
  update_with: Statement,
  next_expression: Expression(type_),
) -> Expression(type_) {
  case next_expression.internal {
    Block(expressions) ->
      Expression(
        internal: Block([update_with, ..expressions]),
        type_: next_expression.type_,
      )
    _ ->
      Expression(
        internal: Block([
          update_with,
          ExpressionStatement(to_dynamic(next_expression)),
        ]),
        type_: next_expression.type_,
      )
  }
}

@internal
pub fn add_statements_to_or_create_block(
  update_with: List(Statement),
  next_expression: Expression(type_),
) -> Expression(type_) {
  case next_expression.internal {
    Block(statements) ->
      Expression(
        internal: Block(list.append(update_with, statements)),
        type_: next_expression.type_,
      )
    _ ->
      Expression(
        internal: Block(
          list.append(update_with, [
            ExpressionStatement(to_dynamic(next_expression)),
          ]),
        ),
        type_: next_expression.type_,
      )
  }
}

@internal
pub fn new_use(
  function: Expression(a),
  args,
  callback_args,
) -> Expression(types.Dynamic) {
  let return = types.get_return_type(function.type_)
  Expression(
    internal: Use(function |> to_dynamic(), args, callback_args),
    type_: return,
  )
}

@internal
pub fn new_case(
  to_match_on,
  patterns,
  all_can_match_on_multiple,
  return,
) -> Expression(type_) {
  Expression(
    internal: Case(to_match_on, patterns, all_can_match_on_multiple),
    type_: return,
  )
}

@internal
pub fn new_anonymous_function(
  function: fn(render.Context) -> render.Rendered,
  return: types.GeneratedType(type_),
) -> Expression(type_) {
  Expression(internal: AnonymousFunction(function), type_: return)
}

/// Get the internal type of an expression
pub fn type_(expr: Expression(t)) -> types.GeneratedType(t) {
  expr.type_
}

// ----------------------------------------------------------------------------
// Expression type conversion functions
// ----------------------------------------------------------------------------

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_dynamic(type_: Expression(t)) -> Expression(types.Dynamic)

/// Convert an expression to any type without checking
@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn coerce_dynamic_unsafe(type_: Expression(t1)) -> Expression(t2)

// ----------------------------------------------------------------------------
// Statements
// ----------------------------------------------------------------------------

@internal
pub type Statement {
  LetDeclaration(name: String, value: Expression(types.Dynamic), assert_: Bool)
  ExpressionStatement(Expression(types.Dynamic))
}

// ----------------------------------------------------------------------------
// Rendering functions
// ----------------------------------------------------------------------------

pub fn render(
  expression: Expression(t),
  context: render.Context,
) -> render.Rendered {
  case expression.internal {
    IntLiteral(value) ->
      value
      |> int.to_string()
      |> doc.from_string()
      |> render.Render(details: render.empty_details)
    FloatLiteral(value) ->
      value
      |> float.to_string()
      |> doc.from_string()
      |> render.Render(details: render.empty_details)
    StrLiteral(value) ->
      render.escape_string(value)
      |> doc.from_string()
      |> render.Render(details: render.empty_details)
    BoolLiteral(True) ->
      doc.from_string("True") |> render.Render(details: render.empty_details)
    BoolLiteral(False) ->
      doc.from_string("False") |> render.Render(details: render.empty_details)
    NilLiteral ->
      doc.from_string("Nil") |> render.Render(details: render.empty_details)
    ListLiteral(values, initial_list) ->
      render_list(values, initial_list, context)
    TupleLiteral(values) -> render_tuple(values, context)
    Ident(value) -> {
      let used_imports = case string.split_once(value, ".") {
        Ok(#(module, _)) -> [module]
        Error(Nil) -> []
      }
      doc.from_string(value)
      |> render.Render(
        details: render.RenderedDetails(..render.empty_details, used_imports:),
      )
    }
    RawDoc(doc) -> render.Render(doc, details: render.empty_details)
    Todo(as_string) ->
      render_panicking_expression(doc.from_string("todo"), as_string)
      |> render.Render(details: render.empty_details)
    Panic(as_string) ->
      render_panicking_expression(doc.from_string("panic"), as_string)
      |> render.Render(details: render.empty_details)
    Assert(condition:, as_string:) -> {
      let assert_ = create_assert(condition, context)
      render_panicking_expression(assert_.doc, as_string)
      |> render.Render(details: assert_.details)
    }
    Echo(expression:, as_string:) -> {
      let echo_ = create_echo(expression, context)
      render_panicking_expression(echo_.doc, as_string)
      |> render.Render(details: echo_.details)
    }
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
        },
        context,
      )
    Comparison(expr1, operator, expr2) -> {
      let operator_doc = case operator {
        GreaterThan -> doc.from_string(">")
        GreaterThanOrEqual -> doc.from_string(">=")
        LessThan -> doc.from_string("<")
        LessThanOrEqual -> doc.from_string("<=")
      }
      render_operator(expr1, expr2, operator_doc, context)
    }
    ComparisonFloat(expr1, operator, expr2) -> {
      let operator_doc = case operator {
        GreaterThan -> doc.from_string(">.")
        GreaterThanOrEqual -> doc.from_string(">=.")
        LessThan -> doc.from_string("<.")
        LessThanOrEqual -> doc.from_string("<=.")
      }
      render_operator(expr1, expr2, operator_doc, context)
    }
    Call(func, args) -> render_call(func, args, context)
    SingleConstructor(constructor) -> render_constructor(constructor, context)
    Block(expressions) -> render_block(expressions, context)
    Equals(expr1, expr2) ->
      render_operator(expr1, expr2, doc.from_string("=="), context)
    NotEquals(expr1, expr2) ->
      render_operator(expr1, expr2, doc.from_string("!="), context)
    Case(to_match_on, patterns, all_can_match_on_multiple) ->
      render_case(to_match_on, patterns, all_can_match_on_multiple, context)
    AnonymousFunction(renderer) -> renderer(context)
    Use(func, args, callback_args) ->
      render_use(func, args, callback_args, context)
  }
}

fn create_echo(
  expression: Expression(types.Dynamic),
  context: render.Context,
) -> render.Rendered {
  let rendered_expr = render(expression, context)
  doc.concat([
    doc.from_string("echo"),
    doc.space,
    rendered_expr.doc,
  ])
  |> render.Render(details: rendered_expr.details)
}

fn create_assert(condition: Expression(Bool), context) -> render.Rendered {
  let rendered_condition = render(condition, context)
  doc.concat([
    doc.from_string("assert"),
    doc.space,
    rendered_condition.doc,
  ])
  |> render.Render(details: rendered_condition.details)
}

fn render_panicking_expression(
  begin_with: doc.Document,
  as_string: Option(String),
) {
  case as_string {
    Some(value) ->
      doc.concat([
        begin_with,
        doc.from_string(" as"),
        doc.space,
        value |> render.escape_string() |> doc.from_string(),
      ])
      |> doc.group
    None -> begin_with
  }
}

fn render_use(func, args, callback_args, context) {
  let use_args =
    callback_args
    |> list.map(doc.from_string)
    |> doc.join(with: doc.concat([doc.from_string(","), doc.space]))
    |> doc.append(case list.is_empty(callback_args) {
      True -> doc.empty
      False -> doc.space
    })
  let call = render_call(func, args, context)

  doc.concat([
    doc.from_string("use"),
    doc.space,
    use_args,
    doc.from_string("<-"),
    doc.space,
    call.doc,
  ])
  |> render.Render(details: call.details)
}

fn render_case(to_match_on, patterns, all_can_match_on_multiple, context) {
  let #(rendered_match_on, subject_count) = case to_match_on.internal {
    TupleLiteral(expressions) if all_can_match_on_multiple -> {
      let #(expressions, details) = render_expressions(expressions, context)
      let rendered_match_on =
        expressions
        |> doc.concat_join([doc.from_string(","), doc.space])
        |> render.Render(details)

      #(rendered_match_on, list.length(expressions))
    }
    _ -> #(render(to_match_on, context), 1)
  }

  let patterns = list.map(patterns, fn(m) { m(context, subject_count) })
  let matcher_details =
    list.fold(
      list.map(patterns, fn(m) { m.details }),
      render.empty_details,
      render.merge_details,
    )

  doc.concat([
    doc.from_string("case "),
    rendered_match_on.doc,
    doc.space,
    render.body(
      patterns
        |> list.map(fn(m) { m.doc })
        |> doc.join(doc.line),
      force_newlines: True,
    ),
  ])
  |> render.Render(details: render.merge_details(
    rendered_match_on.details,
    matcher_details,
  ))
}

fn render_tuple(values, context) {
  let #(rendered_values, details) = render_expressions(values, context)
  rendered_values
  |> render.pretty_list()
  |> doc.prepend(doc.from_string("#"))
  |> render.Render(details: details)
}

fn render_list(values, initial_list, context) {
  let comma = doc.concat([doc.from_string(","), doc.space])

  let #(ending, trailing_comma) = case initial_list {
    Some(initial) -> #(
      doc.concat([
        doc.from_string(","),
        doc.space,
        doc.from_string(".."),
        render(initial, context).doc,
      ]),
      doc.soft_break,
    )
    None -> #(doc.empty, doc.break("", ","))
  }

  let open_bracket = doc.concat([doc.from_string("["), doc.soft_break])
  let close_bracket = doc.concat([trailing_comma, doc.from_string("]")])

  let #(rendered_values, details) = render_expressions(values, context)

  rendered_values
  |> doc.join(with: comma)
  |> doc.prepend(open_bracket)
  |> doc.append(ending)
  |> doc.nest(2)
  |> doc.append(close_bracket)
  |> doc.group
  |> render.Render(details: details)
}

pub fn render_statement(statement: Statement, context) -> render.Rendered {
  case statement {
    LetDeclaration(variable, value, assert_) -> {
      let rendered_value = render(value, context)
      let let_def = case assert_ {
        True -> "let assert "
        False -> "let "
      }
      doc.concat([
        doc.from_string(let_def),
        doc.from_string(variable),
        doc.space,
        doc.from_string("="),
        doc.space,
        rendered_value.doc,
      ])
      |> render.Render(details: rendered_value.details)
    }
    ExpressionStatement(expr) -> render(expr, context)
  }
}

fn render_block(statements, context) {
  let #(inner_statements, details) =
    list.fold(statements, #([], render.empty_details), fn(acc, statement) {
      let rendered =
        render_statement(
          statement,
          render.Context(..context, include_brackets_current_level: True),
        )
      #([rendered.doc, ..acc.0], render.merge_details(rendered.details, acc.1))
    })

  let inner =
    inner_statements
    |> list.reverse()
    |> doc.join(doc.line)

  case context.include_brackets_current_level {
    True -> render.body(inner, force_newlines: True)
    False -> inner
  }
  |> render.Render(details: details)
}

fn render_expressions(
  expressions,
  context,
) -> #(List(doc.Document), render.RenderedDetails) {
  let #(rendered, details) =
    list.fold(expressions, #([], render.empty_details), fn(acc, expr) {
      let rendered = render(expr, context)
      #([rendered.doc, ..acc.0], render.merge_details(rendered.details, acc.1))
    })
  #(rendered |> list.reverse(), details)
}

fn render_call(func, args, context) {
  let #(rendered_args, details) = render_expressions(args, context)
  let caller = render(func, context)
  doc.concat([caller.doc, render.pretty_list(rendered_args)])
  |> render.Render(details: render.merge_details(details, caller.details))
}

fn render_constructor(func, context) {
  render(func, context)
}

fn render_operator(
  expr1: Expression(type_),
  expr2: Expression(type_),
  rendered_op: doc.Document,
  context: render.Context,
) {
  let first_rendered = render(expr1, context)
  let second_rendered = render(expr2, context)
  doc.concat([
    first_rendered.doc,
    doc.space,
    rendered_op,
    doc.space,
    second_rendered.doc,
  ])
  |> render.Render(details: render.merge_details(
    first_rendered.details,
    second_rendered.details,
  ))
}
// vim: foldmethod=marker foldlevel=0
