//// ## Generating Expressions:
//// ### Literals:
//// - [`int`](#int)
//// - [`float`](#float)
//// - [`string`](#string)
//// - [`bool`](#bool)
//// - [`nil`](#nil)
//// - [`list`](#list)
//// - tuple literals ([`tuple1`](#tuple1), [`tuple2`](#tuple2), [`tuple3`](#tuple3), [`tuple4`](#tuple4), [`tuple5`](#tuple5), [`tuple6`](#tuple6), [`tuple7`](#tuple7), [`tuple8`](#tuple8), [`tuple9`](#tuple9))
//// ### Operators:
//// - [`comparison`](#comparison)
//// - [`comparison_float`](#comparison_float)
//// - [`math_operator`](#math_operator)
//// - [`math_operator_float`](#math_operator_float)
//// - [`equals`](#equals)
//// - [`not_equals`](#not_equals)
//// - [`list_prepend`](#list_prepend)
//// ### Keywords:
//// - [`echo_`](#echo_)
//// - [`todo_`](#todo_)
//// - [`panic_`](#panic_)
//// - [`assert_`](#assert_)
//// ### Other expressions:
//// - [`ok`](#ok)
//// - [`error`](#error)
//// - [`option_some`](#option_some)
//// - [`option_none`](#option_none)
//// - constructors ([`construct0`](#construct0), [`construct1`](#construct1), [`construct2`](#construct2), [`construct3`](#construct3), [`construct4`](#construct4), [`construct5`](#construct5), [`construct6`](#construct6), [`construct7`](#construct7), [`construct8`](#construct8), [`construct9`](#construct9))
//// - call expressions ([`call0`](#call0), [`call1`](#call1), [`call2`](#call2), [`call3`](#call3), [`call4`](#call4), [`call5`](#call5), [`call6`](#call6), [`call7`](#call7), [`call8`](#call8), [`call9`](#call9))
//// - import from other files ([`import_.value_of_type`](import_.html#value_of_type), [`import_.raw_ident`](import_.html#raw_ident))
//// ### Creating dynamic expressions:
//// - [`raw`](#raw)
//// - [`raw_of_type`](#raw_of_type)
//// - [`call_dynamic`](#call_dynamic)
//// - [`to_dynamic`](#to_dynamic)
//// - [`coerce_dynamic_unsafe`](#coerce_dynamic_unsafe)
//// ## Using expressions:
//// - [`render`](#render)
//// - [`type_`](#type_)

import glam/doc
import gleam/bool
import gleam/dict
import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleamgen/internal/import_reference
import gleamgen/internal/render
import gleamgen/parameter
import gleamgen/render as public_render
import gleamgen/render/config
import gleamgen/type_

pub opaque type Expression(type_) {
  Expression(
    internal: InternalExpression(type_),
    type_: type_.GeneratedType(type_),
  )
}

type InternalExpression(type_) {
  IntLiteral(Int)
  FloatLiteral(Float)
  StrLiteral(String)
  BoolLiteral(Bool)
  NilLiteral
  ListLiteral(
    prepending: List(Expression(type_.Dynamic)),
    initial: Option(Expression(type_.Dynamic)),
  )
  Equals(Expression(type_.Dynamic), Expression(type_.Dynamic))
  NotEquals(Expression(type_.Dynamic), Expression(type_.Dynamic))
  TupleLiteral(List(Expression(type_.Dynamic)))
  Ident(String)
  ImportedIdent(import_reference.ImportReference, String)
  RawDoc(doc.Document)
  Todo(Option(String))
  Panic(Option(String))
  Echo(expression: Expression(type_.Dynamic), as_string: Option(String))
  Assert(condition: Expression(type_.Dynamic), as_string: Option(String))
  MathOperator(
    Expression(type_.Dynamic),
    MathOperator,
    Expression(type_.Dynamic),
  )
  MathOperatorFloat(
    Expression(type_.Dynamic),
    MathOperator,
    Expression(type_.Dynamic),
  )
  BoolOperator(
    Expression(type_.Dynamic),
    BoolOperator,
    Expression(type_.Dynamic),
  )
  Comparison(Expression(type_.Dynamic), Comparison, Expression(type_.Dynamic))
  ComparisonFloat(
    Expression(type_.Dynamic),
    Comparison,
    Expression(type_.Dynamic),
  )
  ConcatString(Expression(type_.Dynamic), Expression(type_.Dynamic))
  Call(Expression(type_.Dynamic), List(Expression(type_.Dynamic)))
  SingleConstructor(Expression(type_.Dynamic))
  Block(List(Statement))
  Case(
    Expression(type_.Dynamic),
    fn(render.Context) -> List(fn(Int) -> render.Rendered),
    Bool,
  )
  AnonymousFunction(
    render: fn(render.Context) -> render.Rendered,
    body: Expression(type_.Dynamic),
    parameters: List(parameter.Parameter(type_.Dynamic)),
  )
  Use(
    function: Expression(type_.Dynamic),
    args: List(Expression(type_.Dynamic)),
    callback_args: List(String),
  )
  WithConfig(Expression(type_.Dynamic), config.Config)
}

// ----------------------------------------------------------------------------
// Expression functions
// ----------------------------------------------------------------------------

/// Create an integer literal expression.
///
/// ```gleam
/// expression.int(42) // Expression(Int) -> 42
/// ```
pub fn int(value: Int) -> Expression(Int) {
  Expression(IntLiteral(value), type_.int)
}

/// Create a float literal expression.
///
/// ```gleam
/// expression.float(3.14) // Expression(Float) -> 3.14
/// ```
pub fn float(value: Float) -> Expression(Float) {
  Expression(FloatLiteral(value), type_.float)
}

/// Create a string literal expression.
///
/// ```gleam
/// expression.string("Labas!") // Expression(String) -> "Labas!"
/// ```
pub fn string(value: String) -> Expression(String) {
  Expression(StrLiteral(value), type_.string)
}

/// Create a boolean literal expression.
///
/// ```gleam
/// expression.bool(True) // Expression(Bool) -> True
/// ```
pub fn bool(value: Bool) -> Expression(Bool) {
  Expression(BoolLiteral(value), type_.bool)
}

/// Create a Nil literal expression.
///
/// ```gleam
/// expression.nil() // Expression(Nil) -> Nil
/// ```
pub fn nil() -> Expression(Nil) {
  Expression(NilLiteral, type_.nil)
}

/// Create a list literal expression.
///
/// ```gleam
/// expression.list([
///   expression.int(1),
///   expression.int(2),
///   expression.int(3),
///   expression.int(4),
/// ]) // Expression(List(Int)) -> [1, 2, 3, 4]
/// ```
/// See also [`list_prepend`](#list_prepend).
pub fn list(value: List(Expression(t))) -> Expression(List(t)) {
  Expression(
    ListLiteral(value |> list.map(to_dynamic), None),
    value
      |> list.first()
      |> result.map(type_)
      |> result.lazy_unwrap(fn() { type_.dynamic() })
      |> type_.list(),
  )
}

/// Prepend value(s) to list using `[value, ..original]` syntax.
/// 
/// ```gleam
/// expression.list_prepend(
///   [expression.int(1), expression.int(2)],
///   expression.raw("integers")
/// ) Expression(List(Int)) // -> [1, 2, ..integers]
/// ```
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
      |> result.map(type_.list)
      |> result.unwrap(original.type_),
  )
}

/// Determine if values are equal using `==` syntax.
///
/// ```gleam
/// expression.equals(
///   expression.raw("movie"),
///   expression.string("The Needle")
/// ) // Expression(Bool) -> movie == "The Needle"
/// ```
/// See also: `not_equals`.
pub fn equals(first: Expression(a), second: Expression(a)) -> Expression(Bool) {
  Expression(Equals(first |> to_dynamic(), second |> to_dynamic()), type_.bool)
}

/// Determine if values are not equal using `!=` syntax.
///
/// ```gleam
/// expression.not_equals(
///   expression.raw("movie"),
///   expression.string("The Shining")
/// ) // Expression(Bool) -> movie != "The Shining"
/// ```
/// See also: `equals`.
pub fn not_equals(
  first: Expression(a),
  second: Expression(a),
) -> Expression(Bool) {
  Expression(
    NotEquals(first |> to_dynamic(), second |> to_dynamic()),
    type_.bool,
  )
}

pub fn tuple1(arg1: Expression(a)) -> Expression(#(a)) {
  Expression(TupleLiteral([arg1 |> to_dynamic()]), type_.tuple1(type_(arg1)))
}

// Remaining repetitive tuple functions
// {{{

pub fn tuple2(arg1: Expression(a), arg2: Expression(b)) -> Expression(#(a, b)) {
  Expression(
    TupleLiteral([arg1 |> to_dynamic(), arg2 |> to_dynamic()]),
    type_.tuple2(type_(arg1), type_(arg2)),
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
    type_.tuple3(type_(arg1), type_(arg2), type_(arg3)),
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
    type_.tuple4(type_(arg1), type_(arg2), type_(arg3), type_(arg4)),
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
    type_.tuple5(
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
    type_.tuple6(
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
    type_.tuple7(
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
    type_.tuple8(
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
    type_.tuple9(
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
/// Prefer using `raw_of_type`
pub fn raw(value: String) -> Expression(a) {
  Expression(Ident(value), type_.dynamic())
}

@internal
pub fn raw_doc(value: doc.Document) -> Expression(a) {
  Expression(RawDoc(value), type_.dynamic())
}

@internal
pub fn imported_ident(
  import_reference: import_reference.ImportReference,
  value: String,
) -> Expression(a) {
  Expression(ImportedIdent(import_reference, value), type_.dynamic())
}

/// Provide a string to inject without any checking of the specified type
pub fn raw_of_type(
  value: String,
  type_: type_.GeneratedType(t),
) -> Expression(t) {
  Expression(Ident(value), type_)
}

@internal
pub fn imported_ident_of_type(
  import_reference: import_reference.ImportReference,
  value: String,
  type_: type_.GeneratedType(t),
) -> Expression(t) {
  Expression(ImportedIdent(import_reference, value), type_)
}

/// Use the <> operator to concatenate two strings.
///
/// ```gleam
/// expression.concat_string(expression.raw("greeting"), expression.string("world"))
/// // Expression(String) -> greeting <> "world"
/// ```
pub fn concat_string(
  expr1: Expression(String),
  expr2: Expression(String),
) -> Expression(String) {
  Expression(ConcatString(to_dynamic(expr1), to_dynamic(expr2)), type_.string)
}

/// Create a todo expression with an optional as clause.
///
/// ```gleam
/// expression.todo_(option.Some("some unimplemented thing"))
/// // Expression(a) -> "todo as \"some unimplemented thing\""
/// ```
pub fn todo_(as_string: Option(String)) -> Expression(a) {
  Expression(Todo(as_string), type_.dynamic())
}

/// Create a panic expression with an optional as clause.
///
/// ```gleam
/// expression.panic_(option.Some("ahhhhhh!!!"))
/// // Expression(a) -> "panic as \"ahhhhhh!!!\""
/// ```
pub fn panic_(as_string: Option(String)) -> Expression(a) {
  Expression(Panic(as_string), type_.dynamic())
}

/// Create an assert expression with an optional as clause.
pub fn assert_(
  condition: Expression(Bool),
  as_string: Option(String),
) -> Expression(Nil) {
  Expression(Assert(to_dynamic(condition), as_string), type_.nil)
}

/// Create an echo expression with an optional as clause.
///
/// ```gleam
/// expression.echo_(
///   expression.math_operator(
///     expression.int(2),
///     expression.Add,
///     expression.int(3),
///   ), 
///   option.None
/// ) // Expression(Int) -> echo 2 + 3
/// ```
pub fn echo_(
  expression: Expression(a),
  as_string: Option(String),
) -> Expression(a) {
  Expression(Echo(to_dynamic(expression), as_string), expression.type_)
}

/// Create an Ok value of the result type.
///
/// ```gleam
/// expression.ok(expression.int(5))
/// // Expression(Result(Int, error)) -> Ok(5)
/// ```
pub fn ok(ok_value: Expression(ok)) -> Expression(Result(ok, err)) {
  Expression(
    internal: Call(raw("Ok"), [ok_value |> to_dynamic]),
    type_: type_.result(type_(ok_value), type_.dynamic()),
  )
}

/// Create an Error value of the result type.
///
/// ```gleam
/// expression.error(expression.string("File not found"))
/// // Expression(Result(ok, String)) -> Error("File not found")
/// ```
pub fn error(err_value: Expression(err)) -> Expression(Result(ok, err)) {
  Expression(
    internal: Call(raw("Error"), [err_value |> to_dynamic]),
    type_: type_.result(type_.dynamic(), type_(err_value)),
  )
}

pub fn option_some(value: Expression(t)) -> Expression(option.Option(t)) {
  Expression(
    internal: Call(
      imported_ident(
        import_reference.new_implied_reference(["gleam", "option"]),
        "Some",
      ),
      [to_dynamic(value)],
    ),
    type_: type_.option(value.type_),
  )
}

pub fn option_none() -> Expression(option.Option(t)) {
  Expression(
    internal: SingleConstructor(imported_ident(
      import_reference.new_implied_reference(["gleam", "option"]),
      "None",
    )),
    type_: type_.option(type_.dynamic()),
  )
}

type BoolOperator {
  And
  Or
}

/// Apply the and operator to two expressions with the type of Bool.
///
/// ```gleam
/// expression.and(expression.raw("has_cheese"), expression.raw("wants_cheese"))
/// // Expression(Bool) -> "has_cheese && wants_cheese"
/// ```
pub fn and(expr1: Expression(Bool), expr2: Expression(Bool)) -> Expression(Bool) {
  Expression(
    BoolOperator(to_dynamic(expr1), And, to_dynamic(expr2)),
    type_.bool,
  )
}

/// Apply the or operator to two expressions with the type of Bool.
///
/// ```gleam
/// expression.or(expression.raw("wants_cake"), expression.raw("wants_cheese"))
/// // Expression(Bool) -> "wants_cake || wants_cheese"
/// ```
pub fn or(expr1: Expression(Bool), expr2: Expression(Bool)) -> Expression(Bool) {
  Expression(BoolOperator(to_dynamic(expr1), Or, to_dynamic(expr2)), type_.bool)
}

/// See [`math_operator`](#math_operator) and [`math_operator_flaot`](#math_operator_float)`
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
  Expression(MathOperator(to_dynamic(expr1), op, to_dynamic(expr2)), type_.int)
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
  Expression(
    MathOperatorFloat(to_dynamic(expr1), op, to_dynamic(expr2)),
    type_.int,
  )
}

pub fn comparison(
  expr1: Expression(Int),
  operator: Comparison,
  expr2: Expression(Int),
) -> Expression(Bool) {
  Expression(
    Comparison(to_dynamic(expr1), operator, to_dynamic(expr2)),
    type_.bool,
  )
}

pub fn comparison_float(
  expr1: Expression(Float),
  operator: Comparison,
  expr2: Expression(Float),
) -> Expression(Bool) {
  Expression(
    ComparisonFloat(to_dynamic(expr1), operator, to_dynamic(expr2)),
    type_.bool,
  )
}

/// Call a function or constructor with no arguments
///
/// ```gleam
/// expression.call0(
///   import_.value_of_type(dict_module, "new", types.reference(dict.new))
/// ) // Expression(dict.Dict(key, value)) -> "dict.new()"
/// ```
pub fn call0(func: Expression(fn() -> ret)) -> Expression(ret) {
  Expression(internal: Call(func |> to_dynamic, []), type_: type_.dynamic())
}

/// Call a function or constructor with one argument.
///
/// ```gleam
/// expression.call1(
///   import_.value_of_type(list_module, "is_empty", types.reference(list.is_empty))
///   expression.list([])
/// ) // Expression(Bool) -> "list.is_empty([])"
/// ```
/// To call with a dynamic number of arguments, use [`call_dynamic`](#call_dynamic).
pub fn call1(
  func: Expression(fn(arg1) -> ret),
  arg1: Expression(arg1),
) -> Expression(ret) {
  Expression(
    internal: Call(func |> to_dynamic, [arg1 |> to_dynamic]),
    type_: type_.dynamic(),
  )
}

// remaining repetitive call functions
// {{{

/// Call a function or constructor with two arguments.
/// See [`call1`](#call1).
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
    type_: type_.dynamic(),
  )
}

/// Call a function or constructor with three arguments.
/// See [`call1`](#call1).
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
    type_: type_.dynamic(),
  )
}

/// Call a function or constructor with four arguments.
/// See [`call1`](#call1).
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
    type_: type_.dynamic(),
  )
}

/// Call a function or constructor with five arguments.
/// See [`call1`](#call1).
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
    type_: type_.dynamic(),
  )
}

/// Call a function or constructor with six arguments.
/// See [`call1`](#call1).
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
    type_: type_.dynamic(),
  )
}

/// Call a function or constructor with seven arguments.
/// See [`call1`](#call1).
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
    type_: type_.dynamic(),
  )
}

/// Call a function or constructor with eight arguments.
/// See [`call1`](#call1).
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
    type_: type_.dynamic(),
  )
}

/// Call a function or constructor with nine arguments.
/// See [`call1`](#call1).
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
    type_: type_.dynamic(),
  )
}

// }}}

/// Call a function or constructor without type checking
pub fn call_dynamic(
  func: Expression(type_.Dynamic),
  args: List(Expression(type_.Dynamic)),
) -> Expression(type_.Dynamic) {
  Expression(internal: Call(func, args), type_: type_.dynamic())
}

pub fn construct0(constructor: Expression(fn() -> ret)) -> Expression(ret) {
  Expression(
    internal: SingleConstructor(constructor |> to_dynamic),
    type_: type_.dynamic(),
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
pub fn update_or_create_block(
  update_with: fn(List(Statement)) -> List(Statement),
  next_expression: Expression(type_),
) -> Expression(type_) {
  case next_expression.internal {
    Block(expressions) ->
      Expression(
        internal: Block(update_with(expressions)),
        type_: next_expression.type_,
      )
    _ ->
      Expression(
        internal: Block(
          update_with([
            ExpressionStatement(to_dynamic(next_expression)),
          ]),
        ),
        type_: next_expression.type_,
      )
  }
}

@internal
pub fn add_to_or_create_block(
  update_with: Statement,
  next_expression: Expression(type_),
) -> Expression(type_) {
  update_or_create_block(
    fn(statements) { [update_with, ..statements] },
    next_expression,
  )
}

@internal
pub fn new_use(
  function: Expression(a),
  args,
  callback_args,
) -> Expression(type_.Dynamic) {
  let return = type_.get_return_type(function.type_)
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
  function_body: Expression(type_.Dynamic),
  function_parameters: List(parameter.Parameter(type_.Dynamic)),
  return: type_.GeneratedType(type_),
) -> Expression(type_) {
  Expression(
    internal: AnonymousFunction(function, function_body, function_parameters),
    type_: return,
  )
}

/// Get the internal type of an expression
pub fn type_(expr: Expression(t)) -> type_.GeneratedType(t) {
  expr.type_
}

pub fn with_render_config(
  expression: Expression(t),
  config: config.Config,
) -> Expression(t) {
  Expression(
    internal: WithConfig(to_dynamic(expression), config),
    type_: expression.type_,
  )
}

// ----------------------------------------------------------------------------
// Expression type conversion functions
// ----------------------------------------------------------------------------

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_dynamic(type_: Expression(t)) -> Expression(type_.Dynamic)

/// Convert an expression to any type without checking
@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn coerce_dynamic_unsafe(type_: Expression(t1)) -> Expression(t2)

// ----------------------------------------------------------------------------
// Statements
// ----------------------------------------------------------------------------

@internal
pub type Statement {
  LetDeclaration(
    pattern: fn(render.Context) -> render.Rendered,
    value: Expression(type_.Dynamic),
    assert_: Bool,
  )
  ExpressionStatement(Expression(type_.Dynamic))
  Comment(List(String))
  Linebreak
}

// ----------------------------------------------------------------------------
// Rendering functions
// ----------------------------------------------------------------------------

pub fn render(
  expression: Expression(t),
  context: public_render.Context,
) -> public_render.Rendered {
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
      let used_imports = case
        string.split_once(value, "."),
        is_minimal_ident(value)
      {
        Ok(#(module, _)), True -> [module]
        _, _ -> []
      }
      doc.from_string(value)
      |> render.Render(
        details: render.RenderedDetails(..render.empty_details, used_imports:),
      )
    }
    ImportedIdent(module, value) -> {
      let module_to_use = render.get_import_from_context(context, module)
      let representation = import_reference.get_reference(module_to_use, value)

      representation
      |> render.Render(render.add_import_to_details(
        render.empty_details,
        module,
      ))
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
    BoolOperator(expr1, And, expr2) ->
      render_operator(expr1, expr2, doc.from_string("&&"), context)
    BoolOperator(expr1, Or, expr2) ->
      render_operator(expr1, expr2, doc.from_string("||"), context)
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
    AnonymousFunction(renderer, ..) -> renderer(context)
    Use(func, args, callback_args) ->
      render_use(func, args, callback_args, context)
    WithConfig(expr, config) ->
      render(coerce_dynamic_unsafe(expr), render.Context(..context, config:))
  }
}

fn create_echo(
  expression: Expression(type_.Dynamic),
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

fn create_assert(
  condition: Expression(type_.Dynamic),
  context,
) -> render.Rendered {
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

// TODO: clean up
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

  let patterns = list.map(patterns(context), fn(m) { m(subject_count) })
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

@internal
pub fn render_statement(
  statement: Statement,
  context: public_render.Context,
) -> public_render.Rendered {
  case statement {
    LetDeclaration(pattern_renderer, value, assert_) -> {
      let rendered_value = render(value, context)
      let let_def = case assert_ {
        True -> "let assert "
        False -> "let "
      }

      let rendered_pattern = pattern_renderer(context)
      let details =
        render.merge_details(rendered_value.details, rendered_pattern.details)

      let #(type_annotation, details) = case
        type_.render_type(value.type_, context)
      {
        Ok(rendered_type) if context.config.annotate_type_in_let_declarations -> #(
          doc.concat([
            doc.from_string(":"),
            doc.space,
            rendered_type.doc,
          ]),
          render.merge_details(details, rendered_type.details),
        )
        _ -> #(doc.empty, details)
      }

      doc.concat([
        doc.from_string(let_def),
        rendered_pattern.doc,
        type_annotation,
        doc.space,
        doc.from_string("="),
        doc.space,
        rendered_value.doc,
      ])
      |> render.Render(details: details)
    }
    Comment(comments) ->
      comments
      |> list.map(fn(comment) { doc.from_string("// " <> comment) })
      |> doc.join(doc.line)
      |> render.Render(details: render.empty_details)
    Linebreak -> render.Render(doc.empty, render.empty_details)
    ExpressionStatement(Expression(
      WithConfig(Expression(internal: Block(statements), ..), config),
      ..,
    )) -> {
      render_block(
        statements,
        render.Context(
          ..context,
          include_brackets_current_level: False,
          config:,
        ),
      )
    }
    ExpressionStatement(expr) -> render(expr, context)
  }
}

fn render_block(statements, context) {
  let corrected_statements = remove_incorrect_empty_lines(statements)

  // A block that only contains one expression does not need `{ ... }`; same
  // rule as for call arguments (e.g. `let y = x + 1` not `let y = { x + 1 }`).
  case corrected_statements {
    [ExpressionStatement(expr)] ->
      render(
        expr,
        render.Context(..context, include_brackets_current_level: True),
      )
    _ -> render_block_multi_statement(corrected_statements, context)
  }
}

fn render_block_multi_statement(statements, context) {
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

fn remove_incorrect_empty_lines(statements) {
  let trimmed_beginning =
    list.drop_while(statements, fn(statement) { statement == Linebreak })

  do_remove_incorrect_empty_lines(trimmed_beginning, [], False)
}

fn do_remove_incorrect_empty_lines(statements, acc, was_just_empty_line: Bool) {
  case statements {
    [] -> list.reverse(acc)
    [Linebreak, ..rest] -> do_remove_incorrect_empty_lines(rest, acc, True)
    [other, ..rest] if was_just_empty_line ->
      do_remove_incorrect_empty_lines(rest, [other, Linebreak, ..acc], False)
    [other, ..rest] ->
      do_remove_incorrect_empty_lines(rest, [other, ..acc], False)
  }
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
  // Arguments use bracket semantics at the root so multi-statement blocks stay
  // wrapped even when this call is rendered with `include_brackets_current_level: False`
  // (e.g. as a function body).
  let arg_context =
    render.Context(..context, include_brackets_current_level: True)
  let #(rendered_args, details) = render_expressions(args, arg_context)
  case inline_anonymous_function_args(func, rendered_args, details, context) {
    Ok(inlined) -> inlined
    Error(Nil) -> {
      let caller = render(func, context)
      doc.concat([caller.doc, render.pretty_list(rendered_args)])
      |> render.Render(details: render.merge_details(details, caller.details))
    }
  }
}

fn inline_anonymous_function_args(
  function_expression: Expression(a),
  rendered_args,
  details,
  context,
) {
  case function_expression.internal {
    AnonymousFunction(body:, parameters:, ..) -> {
      use <- bool.guard(
        list.length(parameters) != list.length(rendered_args),
        Error(Nil),
      )

      let rendered_parameters_by_name =
        parameters
        |> list.map(fn(parameter) { parameter.name(parameter) })
        |> list.zip(rendered_args)
        |> dict.from_list

      use inlined_body <- result.try(
        recursively_update_expression(body, fn(expr, run_update) {
          inline_with(expr, run_update, rendered_parameters_by_name)
        }),
      )
      let rendered_inlined_body = render(inlined_body, context)
      Ok(render.Render(
        rendered_inlined_body.doc,
        details: render.merge_details(details, rendered_inlined_body.details),
      ))
    }
    _ -> Error(Nil)
  }
}

fn inline_with(
  expression: Expression(type_.Dynamic),
  run_update: fn(Expression(type_.Dynamic)) ->
    Result(Expression(type_.Dynamic), Nil),
  rendered_parameters_by_name: dict.Dict(String, doc.Document),
) -> Result(Expression(type_.Dynamic), Nil) {
  case expression.internal {
    Ident(name) -> {
      case dict.get(rendered_parameters_by_name, name) {
        Ok(rendered_arg) ->
          Ok(Expression(..expression, internal: RawDoc(rendered_arg)))
        Error(Nil) ->
          case is_minimal_ident(name) {
            True -> Ok(expression)
            False -> Error(Nil)
          }
      }
    }
    _ -> run_update(expression)
  }
}

fn is_minimal_ident(ident: String) -> Bool {
  ident
  |> string.to_graphemes()
  |> list.all(fn(c) {
    c == "_"
    || c == "."
    || c == "0"
    || c == "1"
    || c == "2"
    || c == "3"
    || c == "4"
    || c == "5"
    || c == "6"
    || c == "7"
    || c == "8"
    || c == "9"
    || c == "a"
    || c == "b"
    || c == "c"
    || c == "d"
    || c == "e"
    || c == "f"
    || c == "g"
    || c == "h"
    || c == "i"
    || c == "j"
    || c == "k"
    || c == "l"
    || c == "m"
    || c == "n"
    || c == "o"
    || c == "p"
    || c == "q"
    || c == "r"
    || c == "s"
    || c == "t"
    || c == "u"
    || c == "v"
    || c == "w"
    || c == "x"
    || c == "y"
    || c == "z"
    || c == "A"
    || c == "B"
    || c == "C"
    || c == "D"
    || c == "E"
    || c == "F"
    || c == "G"
    || c == "H"
    || c == "I"
    || c == "J"
    || c == "K"
    || c == "L"
    || c == "M"
    || c == "N"
    || c == "O"
    || c == "P"
    || c == "Q"
    || c == "R"
    || c == "S"
    || c == "T"
    || c == "U"
    || c == "V"
    || c == "W"
    || c == "X"
    || c == "Y"
    || c == "Z"
  })
}

fn recursively_update_expression(
  expression: Expression(type_.Dynamic),
  run_update: fn(
    Expression(type_.Dynamic),
    fn(Expression(type_.Dynamic)) -> Result(Expression(type_.Dynamic), Nil),
  ) ->
    Result(Expression(type_.Dynamic), Nil),
) {
  let default_update = fn(expr: Expression(type_.Dynamic)) {
    let updated_internal = case expr.internal {
      Call(func, args) -> {
        use updated_func <- result.try(recursively_update_expression(
          func,
          run_update,
        ))
        use updated_args <- result.try(
          list.try_map(args, recursively_update_expression(_, run_update)),
        )
        Ok(Call(updated_func, updated_args))
      }

      // TODO
      Case(..) -> Error(Nil)

      // We can't know what these actually contain
      RawDoc(_) | Ident(_) -> Error(Nil)

      // These could change scope
      Block(..) | AnonymousFunction(..) | Use(..) -> Error(Nil)
      WithConfig(expr, config) -> {
        use updated_expr <- result.try(recursively_update_expression(
          expr,
          run_update,
        ))
        Ok(WithConfig(updated_expr, config))
      }
      SingleConstructor(constructor) -> {
        use updated_constructor <- result.try(recursively_update_expression(
          constructor,
          run_update,
        ))
        Ok(SingleConstructor(updated_constructor))
      }
      ListLiteral(elems, initial) -> {
        use updated_elems <- result.try(
          list.try_map(elems, recursively_update_expression(_, run_update)),
        )
        case initial {
          Some(initial) -> {
            use updated_initial <- result.try(recursively_update_expression(
              initial,
              run_update,
            ))
            Ok(ListLiteral(updated_elems, Some(updated_initial)))
          }
          None -> Ok(ListLiteral(updated_elems, None))
        }
      }
      TupleLiteral(elems) -> {
        use updated_elems <- result.try(
          list.try_map(elems, recursively_update_expression(_, run_update)),
        )
        Ok(TupleLiteral(updated_elems))
      }
      Equals(expr1, expr2) -> {
        use updated_expr1 <- result.try(recursively_update_expression(
          expr1,
          run_update,
        ))
        use updated_expr2 <- result.try(recursively_update_expression(
          expr2,
          run_update,
        ))
        Ok(Equals(updated_expr1, updated_expr2))
      }
      NotEquals(expr1, expr2) -> {
        use updated_expr1 <- result.try(recursively_update_expression(
          expr1,
          run_update,
        ))
        use updated_expr2 <- result.try(recursively_update_expression(
          expr2,
          run_update,
        ))
        Ok(NotEquals(updated_expr1, updated_expr2))
      }
      ConcatString(expr1, expr2) -> {
        use updated_expr1 <- result.try(recursively_update_expression(
          expr1,
          run_update,
        ))
        use updated_expr2 <- result.try(recursively_update_expression(
          expr2,
          run_update,
        ))
        Ok(ConcatString(updated_expr1, updated_expr2))
      }
      MathOperator(expr1, op, expr2) -> {
        use updated_expr1 <- result.try(recursively_update_expression(
          expr1,
          run_update,
        ))
        use updated_expr2 <- result.try(recursively_update_expression(
          expr2,
          run_update,
        ))
        Ok(MathOperator(updated_expr1, op, updated_expr2))
      }
      MathOperatorFloat(expr1, op, expr2) -> {
        use updated_expr1 <- result.try(recursively_update_expression(
          expr1,
          run_update,
        ))
        use updated_expr2 <- result.try(recursively_update_expression(
          expr2,
          run_update,
        ))
        Ok(MathOperatorFloat(updated_expr1, op, updated_expr2))
      }
      Comparison(expr1, operator, expr2) -> {
        use updated_expr1 <- result.try(recursively_update_expression(
          expr1,
          run_update,
        ))
        use updated_expr2 <- result.try(recursively_update_expression(
          expr2,
          run_update,
        ))
        Ok(Comparison(updated_expr1, operator, updated_expr2))
      }
      BoolOperator(expr1, operator, expr2) -> {
        use updated_expr1 <- result.try(recursively_update_expression(
          expr1,
          run_update,
        ))
        use updated_expr2 <- result.try(recursively_update_expression(
          expr2,
          run_update,
        ))
        Ok(BoolOperator(updated_expr1, operator, updated_expr2))
      }
      ComparisonFloat(expr1, operator, expr2) -> {
        use updated_expr1 <- result.try(recursively_update_expression(
          expr1,
          run_update,
        ))
        use updated_expr2 <- result.try(recursively_update_expression(
          expr2,
          run_update,
        ))
        Ok(ComparisonFloat(updated_expr1, operator, updated_expr2))
      }
      Echo(expression, as_string) -> {
        use updated_expression <- result.try(recursively_update_expression(
          expression,
          run_update,
        ))
        Ok(Echo(updated_expression, as_string))
      }
      Assert(condition, as_string) -> {
        use updated_condition <- result.try(recursively_update_expression(
          condition,
          run_update,
        ))
        Ok(Assert(updated_condition, as_string))
      }

      IntLiteral(..)
      | StrLiteral(..)
      | BoolLiteral(..)
      | FloatLiteral(..)
      | Panic(..)
      | Todo(..)
      | ImportedIdent(..)
      | NilLiteral -> Ok(expr.internal)
    }
    use internal <- result.try(updated_internal)
    Ok(Expression(internal:, type_: expr.type_))
  }
  run_update(expression, default_update)
}

// Needed for silly gleam phantom type reasons
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
