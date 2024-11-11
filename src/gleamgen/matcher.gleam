import glam/doc
import gleamgen/expression.{type Expression}
import gleamgen/render
import gleamgen/types

pub opaque type Matcher(input, match_output) {
  Variable(String, output: match_output)
  StringLiteral(String, output: match_output)
}

pub fn variable(name: String) -> Matcher(a, Expression(a)) {
  Variable(name, output: expression.unchecked_ident(name))
}

pub fn string_literal(literal: String) -> Matcher(String, Nil) {
  StringLiteral(literal, output: Nil)
}

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
  }
  |> render.Render
}
