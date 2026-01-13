import glam/doc
import gleam/int
import gleam/list
import gleamgen/expression.{type Expression}
import gleamgen/expression/constructor
import gleamgen/render
import gleamgen/types
import gleamgen/types/custom

pub opaque type Pattern(input, match_output) {
  Variable(name: String, output: match_output)
  StringLiteral(contents: String, output: match_output)
  StringConcat(contents: #(String, String), output: match_output)
  IntLiteral(contents: Int, output: match_output)
  BoolLiteral(contents: Bool, output: match_output)
  Tuple(
    contents: List(Pattern(types.Dynamic, types.Dynamic)),
    output: match_output,
  )
  Constructor(
    constructor: #(String, List(Pattern(types.Dynamic, types.Dynamic))),
    output: match_output,
  )
  Or(
    options: #(Pattern(input, match_output), Pattern(input, match_output)),
    output: match_output,
  )
  As(
    options: #(Pattern(types.Dynamic, types.Dynamic), String),
    output: match_output,
  )
}

pub fn variable(name: String) -> Pattern(a, Expression(a)) {
  Variable(name, output: expression.raw(name))
}

pub fn string_literal(literal: String) -> Pattern(a, Nil) {
  StringLiteral(literal, output: Nil)
}

pub fn discard() -> Pattern(a, Nil) {
  Variable("_", output: Nil)
}

pub fn named_discard(name: String) -> Pattern(a, Nil) {
  Variable("_" <> name, output: Nil)
}

pub fn int_literal(literal: Int) -> Pattern(Int, Nil) {
  IntLiteral(literal, output: Nil)
}

pub fn bool_literal(literal: Bool) -> Pattern(Bool, Nil) {
  BoolLiteral(literal, output: Nil)
}

/// Match a string that starts with `initial`
/// ```gleam
/// case_.new(expression.string("I love gleam"))
/// |> case_.with_pattern(
///   pattern.concat_string(starting: "I love ", variable: "thing"),
///   fn(thing) {
///     expression.string("I love ")
///     |> expression.concat_string(thing)
///     |> expression.concat_string(expression.string(" too"))
///   },
/// )
/// |> case_.with_pattern(pattern.variable("_"), fn(_) {
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
) -> Pattern(String, Expression(a)) {
  StringConcat(#(initial, variable), output: expression.raw(variable))
}

pub fn ok(ok_pattern: Pattern(a, a_output)) -> Pattern(Result(a, err), a_output) {
  Constructor(#("Ok", [ok_pattern |> to_dynamic]), output: ok_pattern.output)
}

pub fn error(
  err_pattern: Pattern(a, a_output),
) -> Pattern(Result(ok, a), a_output) {
  Constructor(
    #("Error", [err_pattern |> to_dynamic]),
    output: err_pattern.output,
  )
}

/// Use either of the two patterns
/// ```gleam
/// case_.new(expression.string("hello"))
/// |> case_.with_pattern(
///   pattern.or(pattern.string_literal("hello"), pattern.string_literal("hi")),
///   fn(_) { expression.string("world") },
/// )
/// |> case_.with_pattern(pattern.variable("v"), fn(v) {
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
  first: Pattern(input, match_output),
  second: Pattern(input, match_output),
) -> Pattern(input, match_output) {
  Or(#(first, second), output: first.output)
}

pub fn as_(
  original: Pattern(input, _),
  name: String,
) -> Pattern(input, Expression(input)) {
  As(#(original |> to_dynamic(), name), output: expression.raw(name))
}

pub fn from_constructor_dynamic(
  constructor: constructor.Constructor(construct_to, any, generics),
  constructors: List(Pattern(types.Dynamic, types.Dynamic)),
) -> Pattern(construct, List(Expression(types.Dynamic))) {
  Constructor(
    #(constructor.name(constructor), list.map(constructors, to_dynamic)),
    output: list.filter_map(constructors, get_pattern_output),
  )
}

@external(erlang, "gleamgen_ffi", "get_pattern_output")
@external(javascript, "../gleamgen_ffi.mjs", "get_pattern_output")
fn get_pattern_output(
  pattern: Pattern(types.Dynamic, types.Dynamic),
) -> Result(Expression(types.Dynamic), Nil)

pub fn from_constructor0(
  constructor: constructor.Constructor(construct_to, #(), generics),
) -> Pattern(construct_to, Nil) {
  Constructor(#(constructor.name(constructor), []), output: Nil)
}

pub fn from_constructor1(
  constructor: constructor.Constructor(construct_to, #(#(), a), generics),
  first: Pattern(a, a_output),
) -> Pattern(custom.CustomType(construct_to, generics), a_output) {
  Constructor(
    #(constructor.name(constructor), [first |> to_dynamic]),
    output: first.output,
  )
}

// rest of repetitive constructors
// {{{

pub fn from_constructor2(
  constructor: constructor.Constructor(construct_to, #(#(#(), a), b), generics),
  first: Pattern(a, a_output),
  second: Pattern(b, b_output),
) -> Pattern(custom.CustomType(construct_to, generics), #(a_output, b_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_dynamic,
      second |> to_dynamic,
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
  first: Pattern(a, a_output),
  second: Pattern(b, b_output),
  third: Pattern(c, c_output),
) -> Pattern(construct_to, #(a_output, b_output, c_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_dynamic,
      second |> to_dynamic,
      third |> to_dynamic,
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
  first: Pattern(a, a_output),
  second: Pattern(b, b_output),
  third: Pattern(c, c_output),
  fourth: Pattern(d, d_output),
) -> Pattern(construct_to, #(a_output, b_output, c_output, d_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_dynamic,
      second |> to_dynamic,
      third |> to_dynamic,
      fourth |> to_dynamic,
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
  first: Pattern(a, a_output),
  second: Pattern(b, b_output),
  third: Pattern(c, c_output),
  fourth: Pattern(d, d_output),
  fifth: Pattern(e, e_output),
) -> Pattern(construct_to, #(a_output, b_output, c_output, d_output, e_output)) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_dynamic,
      second |> to_dynamic,
      third |> to_dynamic,
      fourth |> to_dynamic,
      fifth |> to_dynamic,
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
  first: Pattern(a, a_output),
  second: Pattern(b, b_output),
  third: Pattern(c, c_output),
  fourth: Pattern(d, d_output),
  fifth: Pattern(e, e_output),
  sixth: Pattern(f, f_output),
) -> Pattern(
  construct_to,
  #(a_output, b_output, c_output, d_output, e_output, f_output),
) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_dynamic,
      second |> to_dynamic,
      third |> to_dynamic,
      fourth |> to_dynamic,
      fifth |> to_dynamic,
      sixth |> to_dynamic,
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
  first: Pattern(a, a_output),
  second: Pattern(b, b_output),
  third: Pattern(c, c_output),
  fourth: Pattern(d, d_output),
  fifth: Pattern(e, e_output),
  sixth: Pattern(f, f_output),
  seventh: Pattern(g, g_output),
) -> Pattern(
  construct_to,
  #(a_output, b_output, c_output, d_output, e_output, f_output, g_output),
) {
  Constructor(
    #(constructor.name(constructor), [
      first |> to_dynamic,
      second |> to_dynamic,
      third |> to_dynamic,
      fourth |> to_dynamic,
      fifth |> to_dynamic,
      sixth |> to_dynamic,
      seventh |> to_dynamic,
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
  first: Pattern(a, a_output),
  second: Pattern(b, b_output),
  third: Pattern(c, c_output),
  fourth: Pattern(d, d_output),
  fifth: Pattern(e, e_output),
  sixth: Pattern(f, f_output),
  seventh: Pattern(g, g_output),
  eighth: Pattern(h, h_output),
) -> Pattern(
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
      first |> to_dynamic,
      second |> to_dynamic,
      third |> to_dynamic,
      fourth |> to_dynamic,
      fifth |> to_dynamic,
      sixth |> to_dynamic,
      seventh |> to_dynamic,
      eighth |> to_dynamic,
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
  first: Pattern(a, a_output),
  second: Pattern(b, b_output),
  third: Pattern(c, c_output),
  fourth: Pattern(d, d_output),
  fifth: Pattern(e, e_output),
  sixth: Pattern(f, f_output),
  seventh: Pattern(g, g_output),
  eighth: Pattern(h, h_output),
  ninth: Pattern(i, i_output),
) -> Pattern(
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
      first |> to_dynamic,
      second |> to_dynamic,
      third |> to_dynamic,
      fourth |> to_dynamic,
      fifth |> to_dynamic,
      sixth |> to_dynamic,
      seventh |> to_dynamic,
      eighth |> to_dynamic,
      ninth |> to_dynamic,
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

pub fn tuple0() -> Pattern(#(), Nil) {
  Tuple([], output: Nil)
}

pub fn tuple1(
  pattern: Pattern(a_input, a_output),
) -> Pattern(#(a_input), #(a_output)) {
  Tuple([pattern |> to_dynamic], output: #(pattern.output))
}

// rest of repetitive tuples
// {{{

pub fn tuple2(
  pattern1: Pattern(a_input, a_output),
  pattern2: Pattern(b_input, b_output),
) -> Pattern(#(a_input, b_input), #(a_output, b_output)) {
  Tuple([pattern1 |> to_dynamic, pattern2 |> to_dynamic], output: #(
    pattern1.output,
    pattern2.output,
  ))
}

pub fn tuple3(
  pattern1: Pattern(a_input, a_output),
  pattern2: Pattern(b_input, b_output),
  pattern3: Pattern(c_input, c_output),
) -> Pattern(#(a_input, b_input, c_input), #(a_output, b_output, c_output)) {
  Tuple(
    [
      pattern1 |> to_dynamic,
      pattern2 |> to_dynamic,
      pattern3 |> to_dynamic,
    ],
    output: #(pattern1.output, pattern2.output, pattern3.output),
  )
}

pub fn tuple4(
  pattern1: Pattern(a_input, a_output),
  pattern2: Pattern(b_input, b_output),
  pattern3: Pattern(c_input, c_output),
  pattern4: Pattern(d_input, d_output),
) -> Pattern(
  #(a_input, b_input, c_input, d_input),
  #(a_output, b_output, c_output, d_output),
) {
  Tuple(
    [
      pattern1 |> to_dynamic,
      pattern2 |> to_dynamic,
      pattern3 |> to_dynamic,
      pattern4 |> to_dynamic,
    ],
    output: #(
      pattern1.output,
      pattern2.output,
      pattern3.output,
      pattern4.output,
    ),
  )
}

pub fn tuple5(
  pattern1: Pattern(a_input, a_output),
  pattern2: Pattern(b_input, b_output),
  pattern3: Pattern(c_input, c_output),
  pattern4: Pattern(d_input, d_output),
  pattern5: Pattern(e_input, e_output),
) -> Pattern(
  #(a_input, b_input, c_input, d_input, e_input),
  #(a_output, b_output, c_output, d_output, e_output),
) {
  Tuple(
    [
      pattern1 |> to_dynamic,
      pattern2 |> to_dynamic,
      pattern3 |> to_dynamic,
      pattern4 |> to_dynamic,
      pattern5 |> to_dynamic,
    ],
    output: #(
      pattern1.output,
      pattern2.output,
      pattern3.output,
      pattern4.output,
      pattern5.output,
    ),
  )
}

pub fn tuple6(
  pattern1: Pattern(a_input, a_output),
  pattern2: Pattern(b_input, b_output),
  pattern3: Pattern(c_input, c_output),
  pattern4: Pattern(d_input, d_output),
  pattern5: Pattern(e_input, e_output),
  pattern6: Pattern(f_input, f_output),
) -> Pattern(
  #(a_input, b_input, c_input, d_input, e_input, f_input),
  #(a_output, b_output, c_output, d_output, e_output, f_output),
) {
  Tuple(
    [
      pattern1 |> to_dynamic,
      pattern2 |> to_dynamic,
      pattern3 |> to_dynamic,
      pattern4 |> to_dynamic,
      pattern5 |> to_dynamic,
      pattern6 |> to_dynamic,
    ],
    output: #(
      pattern1.output,
      pattern2.output,
      pattern3.output,
      pattern4.output,
      pattern5.output,
      pattern6.output,
    ),
  )
}

pub fn tuple7(
  pattern1: Pattern(a_input, a_output),
  pattern2: Pattern(b_input, b_output),
  pattern3: Pattern(c_input, c_output),
  pattern4: Pattern(d_input, d_output),
  pattern5: Pattern(e_input, e_output),
  pattern6: Pattern(f_input, f_output),
  pattern7: Pattern(g_input, g_output),
) -> Pattern(
  #(a_input, b_input, c_input, d_input, e_input, f_input, g_input),
  #(a_output, b_output, c_output, d_output, e_output, f_output, g_output),
) {
  Tuple(
    [
      pattern1 |> to_dynamic,
      pattern2 |> to_dynamic,
      pattern3 |> to_dynamic,
      pattern4 |> to_dynamic,
      pattern5 |> to_dynamic,
      pattern6 |> to_dynamic,
      pattern7 |> to_dynamic,
    ],
    output: #(
      pattern1.output,
      pattern2.output,
      pattern3.output,
      pattern4.output,
      pattern5.output,
      pattern6.output,
      pattern7.output,
    ),
  )
}

pub fn tuple8(
  pattern1: Pattern(a_input, a_output),
  pattern2: Pattern(b_input, b_output),
  pattern3: Pattern(c_input, c_output),
  pattern4: Pattern(d_input, d_output),
  pattern5: Pattern(e_input, e_output),
  pattern6: Pattern(f_input, f_output),
  pattern7: Pattern(g_input, g_output),
  pattern8: Pattern(h_input, h_output),
) -> Pattern(
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
      pattern1 |> to_dynamic,
      pattern2 |> to_dynamic,
      pattern3 |> to_dynamic,
      pattern4 |> to_dynamic,
      pattern5 |> to_dynamic,
      pattern6 |> to_dynamic,
      pattern7 |> to_dynamic,
      pattern8 |> to_dynamic,
    ],
    output: #(
      pattern1.output,
      pattern2.output,
      pattern3.output,
      pattern4.output,
      pattern5.output,
      pattern6.output,
      pattern7.output,
      pattern8.output,
    ),
  )
}

pub fn tuple9(
  pattern1: Pattern(a_input, a_output),
  pattern2: Pattern(b_input, b_output),
  pattern3: Pattern(c_input, c_output),
  pattern4: Pattern(d_input, d_output),
  pattern5: Pattern(e_input, e_output),
  pattern6: Pattern(f_input, f_output),
  pattern7: Pattern(g_input, g_output),
  pattern8: Pattern(h_input, h_output),
  pattern9: Pattern(i_input, i_output),
) -> Pattern(
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
      pattern1 |> to_dynamic,
      pattern2 |> to_dynamic,
      pattern3 |> to_dynamic,
      pattern4 |> to_dynamic,
      pattern5 |> to_dynamic,
      pattern6 |> to_dynamic,
      pattern7 |> to_dynamic,
      pattern8 |> to_dynamic,
      pattern9 |> to_dynamic,
    ],
    output: #(
      pattern1.output,
      pattern2.output,
      pattern3.output,
      pattern4.output,
      pattern5.output,
      pattern6.output,
      pattern7.output,
      pattern8.output,
      pattern9.output,
    ),
  )
}

// }}}

pub fn get_output(pattern: Pattern(_, output)) -> output {
  pattern.output
}

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_dynamic(
  type_: Pattern(input, handler_output),
) -> Pattern(types.Dynamic, types.Dynamic)

pub fn render(
  pattern: Pattern(_, _),
  number_of_subjects: Int,
) -> render.Rendered {
  case pattern {
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
    Constructor(#(name, patterns), ..) -> {
      let #(details, rendered_patterns) =
        patterns
        |> list.map_fold(render.empty_details, fn(acc, m) {
          let rendered = render(m, 1)
          #(render.merge_details(acc, rendered.details), rendered.doc)
        })

      rendered_patterns
      |> render.pretty_list()
      |> doc.prepend(doc.from_string(name))
      |> render.Render(details:)
    }
    Tuple(patterns, ..) -> {
      let #(details, rendered_patterns) =
        patterns
        |> list.map_fold(render.empty_details, fn(acc, m) {
          let rendered = render(m, 1)
          #(render.merge_details(acc, rendered.details), rendered.doc)
        })

      case number_of_subjects {
        1 ->
          rendered_patterns
          |> render.pretty_list()
          |> doc.prepend(doc.from_string("#"))
        _ ->
          rendered_patterns
          |> doc.concat_join([doc.from_string(","), doc.space])
      }
      |> render.Render(details:)
    }
  }
}

pub fn can_match_on_multiple(pattern: Pattern(_, _)) -> Bool {
  case pattern {
    // Or(..) -> True
    Tuple(..) -> True
    Variable(name: "_", ..) -> True
    _ -> False
  }
}
// vim: foldmethod=marker foldlevel=0
