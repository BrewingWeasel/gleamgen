import glam/doc
import gleam/list
import gleamgen/expression.{type Expression}
import gleamgen/expression/constructor
import gleamgen/render
import gleamgen/types

pub opaque type Matcher(input, match_output) {
  Variable(String, output: match_output)
  StringLiteral(String, output: match_output)
  BoolLiteral(Bool, output: match_output)
  Tuple(List(Matcher(types.Unchecked, types.Unchecked)), output: match_output)
  Constructor(
    #(String, List(Matcher(types.Unchecked, types.Unchecked))),
    output: match_output,
  )
}

pub fn variable(name: String) -> Matcher(a, Expression(a)) {
  Variable(name, output: expression.unchecked_ident(name))
}

pub fn string_literal(literal: String) -> Matcher(String, Nil) {
  StringLiteral(literal, output: Nil)
}

pub fn bool_literal(literal: Bool) -> Matcher(Bool, Nil) {
  BoolLiteral(literal, output: Nil)
}

pub fn from_constructor0(
  constructor: constructor.Construtor(construct_to, #()),
) -> Matcher(construct_to, Nil) {
  Constructor(#(constructor.name(constructor), []), output: Nil)
}

pub fn from_constructor1(
  constructor: constructor.Construtor(construct_to, #(#(), a)),
  first: Matcher(a, a_output),
) -> Matcher(construct_to, a_output) {
  Constructor(
    #(constructor.name(constructor), [first |> to_unchecked]),
    output: first.output,
  )
}

// rest of repetitive constructors
// {{{

pub fn from_constructor2(
  constructor: constructor.Construtor(construct_to, #(#(#(), a), b)),
  first: Matcher(a, a_output),
  second: Matcher(b, b_output),
) -> Matcher(construct_to, #(a_output, b_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_unchecked,
      second |> to_unchecked,
    ]),
    output: #(first.output, second.output),
  )
}

pub fn from_constructor3(
  constructor: constructor.Construtor(construct_to, #(#(#(#(), a), b), c)),
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
  constructor: constructor.Construtor(construct_to, #(#(#(#(#(), a), b), c), d)),
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
  constructor: constructor.Construtor(
    construct_to,
    #(#(#(#(#(#(), a), b), c), d), e),
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
  constructor: constructor.Construtor(
    construct_to,
    #(#(#(#(#(#(#(), a), b), c), d), e), f),
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
  constructor: constructor.Construtor(
    construct_to,
    #(#(#(#(#(#(#(#(), a), b), c), d), e), f), g),
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
  constructor: constructor.Construtor(
    construct_to,
    #(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h),
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
  constructor: constructor.Construtor(
    construct_to,
    #(#(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h), i),
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
    BoolLiteral(True, ..) -> doc.from_string("True")
    BoolLiteral(False, ..) -> doc.from_string("False")
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