import glam/doc
import gleam/int
import gleam/list
import gleamgen/expression.{type Expression}
import gleamgen/expression/constructor
import gleamgen/render
import gleamgen/types
import gleamgen/types/custom

pub opaque type Matcher(input, match_output) {
  Variable(name: String, output: match_output)
  StringLiteral(contents: String, output: match_output)
  IntLiteral(contents: Int, output: match_output)
  BoolLiteral(contents: Bool, output: match_output)
  Tuple(
    contents: List(Matcher(types.Unchecked, types.Unchecked)),
    output: match_output,
  )
  Constructor(
    constructor: #(String, List(Matcher(types.Unchecked, types.Unchecked))),
    output: match_output,
  )
  Or(
    options: #(Matcher(input, match_output), Matcher(input, match_output)),
    output: match_output,
  )
  As(
    options: #(Matcher(types.Unchecked, types.Unchecked), String),
    output: match_output,
  )
}

pub fn variable(name: String) -> Matcher(a, Expression(a)) {
  Variable(name, output: expression.unchecked_ident(name))
}

pub fn string_literal(literal: String) -> Matcher(String, Nil) {
  StringLiteral(literal, output: Nil)
}

pub fn int_literal(literal: Int) -> Matcher(Int, Nil) {
  IntLiteral(literal, output: Nil)
}

pub fn bool_literal(literal: Bool) -> Matcher(Bool, Nil) {
  BoolLiteral(literal, output: Nil)
}

/// Use either of the two matchers
/// ```gleam
/// case_.new(expression.string("hello"))
/// |> case_.with_matcher(
///   matcher.or(matcher.string_literal("hello"), matcher.string_literal("hi")),
///   fn(_) { expression.string("world") },
/// )
/// |> case_.with_matcher(matcher.variable("v"), fn(v) {
///   expression.concat_string(v, expression.string(" world"))
/// })
/// |> case_.build_expression()
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "case \"hello\" {
///  \"hello\" | \"hi\" -> \"world\"
///  v -> v <> \" world\"
/// }",
/// ```
pub fn or(
  first: Matcher(input, match_output),
  second: Matcher(input, match_output),
) -> Matcher(input, match_output) {
  Or(#(first, second), output: first.output)
}

pub fn as_(
  original: Matcher(input, _),
  name: String,
) -> Matcher(input, Expression(input)) {
  As(
    #(original |> to_unchecked(), name),
    output: expression.unchecked_ident(name),
  )
}

pub fn from_constructor0(
  constructor: constructor.Constructor(construct_to, #(), generics),
) -> Matcher(construct_to, Nil) {
  Constructor(#(constructor.name(constructor), []), output: Nil)
}

pub fn from_constructor1(
  constructor: constructor.Constructor(construct_to, #(#(), a), generics),
  first: Matcher(a, a_output),
) -> Matcher(custom.CustomType(construct_to, generics), a_output) {
  Constructor(
    #(constructor.name(constructor), [first |> to_unchecked]),
    output: first.output,
  )
}

// rest of repetitive constructors
// {{{

pub fn from_constructor2(
  constructor: constructor.Constructor(construct_to, #(#(#(), a), b), generics),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
) -> Matcher(custom.CustomType(construct_to, generics), #(a_output, b_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
    ]),
    output: #(first.output, second.output),
  )
}

pub fn from_constructor3(
  constructor: constructor.Constructor(
    construct_to,
    #(#(#(#(), a), b), c),
    generics,
  ),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
  third: Matcher(c, c_output),
) -> Matcher(construct_to, #(a_output, b_output, c_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
      third |> to_unchecked,
    ]),
    output: #(first.output, second.output, third.output),
  )
}

pub fn from_constructor4(
  constructor: constructor.Constructor(
    construct_to,
    #(#(#(#(#(), a), b), c), d),
    generics,
  ),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
  third: Matcher(c, c_output),
  fourth: Matcher(d, d_output),
) -> Matcher(construct_to, #(a_output, b_output, c_output, d_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
      third |> to_unchecked,
      fourth |> to_unchecked,
    ]),
    output: #(first.output, second.output, third.output, fourth.output),
  )
}

pub fn from_constructor5(
  constructor: constructor.Constructor(
    construct_to,
    #(#(#(#(#(#(), a), b), c), d), e),
    generics,
  ),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
  third: Matcher(c, c_output),
  fourth: Matcher(d, d_output),
  fifth: Matcher(e, e_output),
) -> Matcher(construct_to, #(a_output, b_output, c_output, d_output, e_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
      third |> to_unchecked,
      fourth |> to_unchecked,
      fifth |> to_unchecked,
    ]),
    output: #(
      first.output,
      second.output,
      third.output,
      fourth.output,
      fifth.output,
    ),
  )
}

pub fn from_constructor6(
  constructor: constructor.Constructor(
    construct_to,
    #(#(#(#(#(#(#(), a), b), c), d), e), f),
    generics,
  ),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
  third: Matcher(c, c_output),
  fourth: Matcher(d, d_output),
  fifth: Matcher(e, e_output),
  sixth: Matcher(f, f_output),
) -> Matcher(
  construct_to,
  #(a_output, b_output, c_output, d_output, e_output, f_output),
) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
      third |> to_unchecked,
      fourth |> to_unchecked,
      fifth |> to_unchecked,
      sixth |> to_unchecked,
    ]),
    output: #(
      first.output,
      second.output,
      third.output,
      fourth.output,
      fifth.output,
      sixth.output,
    ),
  )
}

pub fn from_constructor7(
  constructor: constructor.Constructor(
    construct_to,
    #(#(#(#(#(#(#(#(), a), b), c), d), e), f), g),
    generics,
  ),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
  third: Matcher(c, c_output),
  fourth: Matcher(d, d_output),
  fifth: Matcher(e, e_output),
  sixth: Matcher(f, f_output),
  seventh: Matcher(g, g_output),
) -> Matcher(
  construct_to,
  #(a_output, b_output, c_output, d_output, e_output, f_output, g_output),
) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
      third |> to_unchecked,
      fourth |> to_unchecked,
      fifth |> to_unchecked,
      sixth |> to_unchecked,
      seventh |> to_unchecked,
    ]),
    output: #(
      first.output,
      second.output,
      third.output,
      fourth.output,
      fifth.output,
      sixth.output,
      seventh.output,
    ),
  )
}

pub fn from_constructor8(
  constructor: constructor.Constructor(
    construct_to,
    #(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h),
    generics,
  ),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
  third: Matcher(c, c_output),
  fourth: Matcher(d, d_output),
  fifth: Matcher(e, e_output),
  sixth: Matcher(f, f_output),
  seventh: Matcher(g, g_output),
  eighth: Matcher(h, h_output),
) -> Matcher(
  construct_to,
  #(
    a_output,
    b_output,
    c_output,
    d_output,
    e_output,
    f_output,
    g_output,
    h_output,
  ),
) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
      third |> to_unchecked,
      fourth |> to_unchecked,
      fifth |> to_unchecked,
      sixth |> to_unchecked,
      seventh |> to_unchecked,
      eighth |> to_unchecked,
    ]),
    output: #(
      first.output,
      second.output,
      third.output,
      fourth.output,
      fifth.output,
      sixth.output,
      seventh.output,
      eighth.output,
    ),
  )
}

pub fn from_constructor9(
  constructor: constructor.Constructor(
    construct_to,
    #(#(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h), i),
    generics,
  ),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
  third: Matcher(c, c_output),
  fourth: Matcher(d, d_output),
  fifth: Matcher(e, e_output),
  sixth: Matcher(f, f_output),
  seventh: Matcher(g, g_output),
  eighth: Matcher(h, h_output),
  ninth: Matcher(i, i_output),
) -> Matcher(
  construct_to,
  #(
    a_output,
    b_output,
    c_output,
    d_output,
    e_output,
    f_output,
    g_output,
    h_output,
    i_output,
  ),
) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
      third |> to_unchecked,
      fourth |> to_unchecked,
      fifth |> to_unchecked,
      sixth |> to_unchecked,
      seventh |> to_unchecked,
      eighth |> to_unchecked,
      ninth |> to_unchecked,
    ]),
    output: #(
      first.output,
      second.output,
      third.output,
      fourth.output,
      fifth.output,
      sixth.output,
      seventh.output,
      eighth.output,
      ninth.output,
    ),
  )
}

// }}}

pub fn tuple0() -> Matcher(#(), Nil) {
  Tuple([], output: Nil)
}

pub fn tuple1(
  matcher: Matcher(a_input, a_output),
) -> Matcher(#(a_input), #(a_output)) {
  Tuple([matcher |> to_unchecked], output: #(matcher.output))
}

// rest of repetitive tuples
// {{{

pub fn tuple2(
  matcher1: Matcher(a_input, a_output),
  matcher2: Matcher(b_input, b_output),
) -> Matcher(#(a_input, b_input), #(a_output, b_output)) {
  Tuple([matcher1 |> to_unchecked, matcher2 |> to_unchecked], output: #(
    matcher1.output,
    matcher2.output,
  ))
}

pub fn tuple3(
  matcher1: Matcher(a_input, a_output),
  matcher2: Matcher(b_input, b_output),
  matcher3: Matcher(c_input, c_output),
) -> Matcher(#(a_input, b_input, c_input), #(a_output, b_output, c_output)) {
  Tuple(
    [
      matcher1 |> to_unchecked,
      matcher2 |> to_unchecked,
      matcher3 |> to_unchecked,
    ],
    output: #(matcher1.output, matcher2.output, matcher3.output),
  )
}

pub fn tuple4(
  matcher1: Matcher(a_input, a_output),
  matcher2: Matcher(b_input, b_output),
  matcher3: Matcher(c_input, c_output),
  matcher4: Matcher(d_input, d_output),
) -> Matcher(
  #(a_input, b_input, c_input, d_input),
  #(a_output, b_output, c_output, d_output),
) {
  Tuple(
    [
      matcher1 |> to_unchecked,
      matcher2 |> to_unchecked,
      matcher3 |> to_unchecked,
      matcher4 |> to_unchecked,
    ],
    output: #(
      matcher1.output,
      matcher2.output,
      matcher3.output,
      matcher4.output,
    ),
  )
}

pub fn tuple5(
  matcher1: Matcher(a_input, a_output),
  matcher2: Matcher(b_input, b_output),
  matcher3: Matcher(c_input, c_output),
  matcher4: Matcher(d_input, d_output),
  matcher5: Matcher(e_input, e_output),
) -> Matcher(
  #(a_input, b_input, c_input, d_input, e_input),
  #(a_output, b_output, c_output, d_output, e_output),
) {
  Tuple(
    [
      matcher1 |> to_unchecked,
      matcher2 |> to_unchecked,
      matcher3 |> to_unchecked,
      matcher4 |> to_unchecked,
      matcher5 |> to_unchecked,
    ],
    output: #(
      matcher1.output,
      matcher2.output,
      matcher3.output,
      matcher4.output,
      matcher5.output,
    ),
  )
}

pub fn tuple6(
  matcher1: Matcher(a_input, a_output),
  matcher2: Matcher(b_input, b_output),
  matcher3: Matcher(c_input, c_output),
  matcher4: Matcher(d_input, d_output),
  matcher5: Matcher(e_input, e_output),
  matcher6: Matcher(f_input, f_output),
) -> Matcher(
  #(a_input, b_input, c_input, d_input, e_input, f_input),
  #(a_output, b_output, c_output, d_output, e_output, f_output),
) {
  Tuple(
    [
      matcher1 |> to_unchecked,
      matcher2 |> to_unchecked,
      matcher3 |> to_unchecked,
      matcher4 |> to_unchecked,
      matcher5 |> to_unchecked,
      matcher6 |> to_unchecked,
    ],
    output: #(
      matcher1.output,
      matcher2.output,
      matcher3.output,
      matcher4.output,
      matcher5.output,
      matcher6.output,
    ),
  )
}

pub fn tuple7(
  matcher1: Matcher(a_input, a_output),
  matcher2: Matcher(b_input, b_output),
  matcher3: Matcher(c_input, c_output),
  matcher4: Matcher(d_input, d_output),
  matcher5: Matcher(e_input, e_output),
  matcher6: Matcher(f_input, f_output),
  matcher7: Matcher(g_input, g_output),
) -> Matcher(
  #(a_input, b_input, c_input, d_input, e_input, f_input, g_input),
  #(a_output, b_output, c_output, d_output, e_output, f_output, g_output),
) {
  Tuple(
    [
      matcher1 |> to_unchecked,
      matcher2 |> to_unchecked,
      matcher3 |> to_unchecked,
      matcher4 |> to_unchecked,
      matcher5 |> to_unchecked,
      matcher6 |> to_unchecked,
      matcher7 |> to_unchecked,
    ],
    output: #(
      matcher1.output,
      matcher2.output,
      matcher3.output,
      matcher4.output,
      matcher5.output,
      matcher6.output,
      matcher7.output,
    ),
  )
}

pub fn tuple8(
  matcher1: Matcher(a_input, a_output),
  matcher2: Matcher(b_input, b_output),
  matcher3: Matcher(c_input, c_output),
  matcher4: Matcher(d_input, d_output),
  matcher5: Matcher(e_input, e_output),
  matcher6: Matcher(f_input, f_output),
  matcher7: Matcher(g_input, g_output),
  matcher8: Matcher(h_input, h_output),
) -> Matcher(
  #(a_input, b_input, c_input, d_input, e_input, f_input, g_input, h_input),
  #(
    a_output,
    b_output,
    c_output,
    d_output,
    e_output,
    f_output,
    g_output,
    h_output,
  ),
) {
  Tuple(
    [
      matcher1 |> to_unchecked,
      matcher2 |> to_unchecked,
      matcher3 |> to_unchecked,
      matcher4 |> to_unchecked,
      matcher5 |> to_unchecked,
      matcher6 |> to_unchecked,
      matcher7 |> to_unchecked,
      matcher8 |> to_unchecked,
    ],
    output: #(
      matcher1.output,
      matcher2.output,
      matcher3.output,
      matcher4.output,
      matcher5.output,
      matcher6.output,
      matcher7.output,
      matcher8.output,
    ),
  )
}

pub fn tuple9(
  matcher1: Matcher(a_input, a_output),
  matcher2: Matcher(b_input, b_output),
  matcher3: Matcher(c_input, c_output),
  matcher4: Matcher(d_input, d_output),
  matcher5: Matcher(e_input, e_output),
  matcher6: Matcher(f_input, f_output),
  matcher7: Matcher(g_input, g_output),
  matcher8: Matcher(h_input, h_output),
  matcher9: Matcher(i_input, i_output),
) -> Matcher(
  #(
    a_input,
    b_input,
    c_input,
    d_input,
    e_input,
    f_input,
    g_input,
    h_input,
    i_input,
  ),
  #(
    a_output,
    b_output,
    c_output,
    d_output,
    e_output,
    f_output,
    g_output,
    h_output,
    i_output,
  ),
) {
  Tuple(
    [
      matcher1 |> to_unchecked,
      matcher2 |> to_unchecked,
      matcher3 |> to_unchecked,
      matcher4 |> to_unchecked,
      matcher5 |> to_unchecked,
      matcher6 |> to_unchecked,
      matcher7 |> to_unchecked,
      matcher8 |> to_unchecked,
      matcher9 |> to_unchecked,
    ],
    output: #(
      matcher1.output,
      matcher2.output,
      matcher3.output,
      matcher4.output,
      matcher5.output,
      matcher6.output,
      matcher7.output,
      matcher8.output,
      matcher9.output,
    ),
  )
}

// }}}

pub fn get_output(matcher: Matcher(_, output)) -> output {
  matcher.output
}

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_unchecked(
  type_: Matcher(input, handler_output),
) -> Matcher(types.Unchecked, types.Unchecked)

pub fn render(matcher: Matcher(_, _)) -> render.Rendered {
  case matcher {
    Variable(name, ..) -> doc.from_string(name)
    StringLiteral(literal, ..) -> doc.from_string("\"" <> literal <> "\"")
    IntLiteral(literal, ..) -> literal |> int.to_string() |> doc.from_string()
    BoolLiteral(True, ..) -> doc.from_string("True")
    BoolLiteral(False, ..) -> doc.from_string("False")
    Or(#(first, second), ..) ->
      doc.concat([
        render(first).doc,
        doc.space,
        doc.from_string("|"),
        doc.space,
        render(second).doc,
      ])
    As(#(original, name), ..) ->
      doc.concat([
        render(original).doc,
        doc.space,
        doc.from_string("as"),
        doc.space,
        doc.from_string(name),
      ])
    Constructor(#(name, matchers), ..) ->
      matchers
      |> list.map(fn(m) { render(m).doc })
      |> render.pretty_list()
      |> doc.prepend(doc.from_string(name))
    Tuple(matchers, ..) ->
      matchers
      |> list.map(fn(m) { render(m).doc })
      |> render.pretty_list()
      |> doc.prepend(doc.from_string("#"))
  }
  |> render.Render
}
// vim: foldmethod=marker foldlevel=0
