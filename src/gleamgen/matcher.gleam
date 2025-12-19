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
  StringConcat(contents: #(String, String), output: match_output)
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

pub fn string_literal(literal: String) -> Matcher(a, Nil) {
  StringLiteral(literal, output: Nil)
}

pub fn discard() -> Matcher(a, Nil) {
  Variable("_", output: Nil)
}

pub fn named_discard(name: String) -> Matcher(a, Nil) {
  Variable("_" <> name, output: Nil)
}

pub fn int_literal(literal: Int) -> Matcher(Int, Nil) {
  IntLiteral(literal, output: Nil)
}

pub fn bool_literal(literal: Bool) -> Matcher(Bool, Nil) {
  BoolLiteral(literal, output: Nil)
}

/// Match a string that starts with `initial`
/// ```gleam
/// case_.new(expression.string("I love gleam"))
/// |> case_.with_matcher(
///   matcher.concat_string(starting: "I love ", variable: "thing"),
///   fn(thing) {
///     expression.string("I love ")
///     |> expression.concat_string(thing)
///     |> expression.concat_string(expression.string(" too"))
///   },
/// )
/// |> case_.with_matcher(matcher.variable("_"), fn(_) {
///   expression.string("interesting")
/// })
/// |> case_.build_expression()
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// // -> "case \"I love gleam\" {
///  \"I love \" <> thing -> \"I love \" <> thing <> \" too\"
///  _ -> \"Interesting\"
/// }"
/// ```
pub fn concat_string(
  starting initial: String,
  variable variable: String,
) -> Matcher(String, Expression(a)) {
  StringConcat(
    #(initial, variable),
    output: expression.unchecked_ident(variable),
  )
}

pub fn ok(ok_matcher: Matcher(a, a_output)) -> Matcher(Result(a, err), a_output) {
  Constructor(#("Ok", [ok_matcher |> to_unchecked]), output: ok_matcher.output)
}

pub fn error(
  err_matcher: Matcher(a, a_output),
) -> Matcher(Result(ok, a), a_output) {
  Constructor(
    #("Error", [err_matcher |> to_unchecked]),
    output: err_matcher.output,
  )
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

pub fn from_constructor_unchecked(
  constructor: constructor.Constructor(construct_to, any, generics),
  constructors: List(Matcher(types.Unchecked, types.Unchecked)),
) -> Matcher(construct, List(Expression(types.Unchecked))) {
  Constructor(
    #(constructor.name(constructor), list.map(constructors, to_unchecked)),
    output: list.filter_map(constructors, get_matcher_output),
  )
}

@external(erlang, "gleamgen_ffi", "get_matcher_output")
@external(javascript, "../gleamgen_ffi.mjs", "get_matcher_output")
fn get_matcher_output(
  matcher: Matcher(types.Unchecked, types.Unchecked),
) -> Result(Expression(types.Unchecked), Nil)

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

pub fn render(
  matcher: Matcher(_, _),
  number_of_subjects: Int,
) -> render.Rendered {
  case matcher {
    Variable(name, ..) ->
      list.repeat(doc.from_string(name), number_of_subjects)
      |> doc.concat_join(with: [doc.from_string(","), doc.space])
      |> render.Render(details: render.empty_details)
    StringLiteral(literal, ..) ->
      render.escape_string(literal)
      |> doc.from_string()
      |> render.Render(details: render.empty_details)
    StringConcat(#(literal, variable), ..) ->
      render.escape_string(literal)
      |> doc.from_string()
      |> doc.append(
        doc.concat([
          doc.space,
          doc.from_string("<>"),
          doc.space,
          doc.from_string(variable),
        ]),
      )
      |> doc.group()
      |> render.Render(details: render.empty_details)
    IntLiteral(literal, ..) ->
      literal
      |> int.to_string()
      |> doc.from_string()
      |> render.Render(details: render.empty_details)
    BoolLiteral(True, ..) ->
      doc.from_string("True") |> render.Render(details: render.empty_details)
    BoolLiteral(False, ..) ->
      doc.from_string("False") |> render.Render(details: render.empty_details)
    Or(#(first, second), ..) -> {
      let rendered_first = render(first, 1)
      let rendered_second = render(second, 1)
      doc.concat([
        rendered_first.doc,
        doc.space,
        doc.from_string("|"),
        doc.space,
        rendered_second.doc,
      ])
      |> render.Render(details: render.merge_details(
        rendered_first.details,
        rendered_second.details,
      ))
    }
    As(#(original, name), ..) -> {
      let original = render(original, 1)
      doc.concat([
        original.doc,
        doc.space,
        doc.from_string("as"),
        doc.space,
        doc.from_string(name),
      ])
      |> render.Render(details: original.details)
    }
    Constructor(#(name, matchers), ..) -> {
      let #(details, rendered_matchers) =
        matchers
        |> list.map_fold(render.empty_details, fn(acc, m) {
          let rendered = render(m, 1)
          #(render.merge_details(acc, rendered.details), rendered.doc)
        })

      rendered_matchers
      |> render.pretty_list()
      |> doc.prepend(doc.from_string(name))
      |> render.Render(details:)
    }
    Tuple(matchers, ..) -> {
      let #(details, rendered_matchers) =
        matchers
        |> list.map_fold(render.empty_details, fn(acc, m) {
          let rendered = render(m, 1)
          #(render.merge_details(acc, rendered.details), rendered.doc)
        })

      case number_of_subjects {
        1 ->
          rendered_matchers
          |> render.pretty_list()
          |> doc.prepend(doc.from_string("#"))
        _ ->
          rendered_matchers
          |> doc.concat_join([doc.from_string(","), doc.space])
      }
      |> render.Render(details:)
    }
  }
}

pub fn can_match_on_multiple(matcher: Matcher(_, _)) -> Bool {
  case matcher {
    // Or(..) -> True
    Tuple(..) -> True
    Variable(name: "_", ..) -> True
    _ -> False
  }
}
// vim: foldmethod=marker foldlevel=0
