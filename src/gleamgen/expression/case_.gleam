import glam/doc
import gleam/list
import gleam/result
import gleamgen/expression.{type Expression}
import gleamgen/matcher.{type Matcher}
import gleamgen/render
import gleamgen/types.{type Unchecked}

pub type CaseExpression(input, output) {
  CaseExpression(
    input_expression: Expression(input),
    cases: List(#(Matcher(Unchecked, Unchecked), Expression(output))),
  )
}

pub fn new(input_expression: Expression(input)) -> CaseExpression(input, a) {
  CaseExpression(input_expression, [])
}

pub fn with_matcher(
  old: CaseExpression(input, output),
  matcher: Matcher(input, matcher_output),
  handler: fn(matcher_output) -> Expression(output),
) {
  CaseExpression(old.input_expression, [
    #(matcher |> matcher.to_unchecked(), handler(matcher.get_output(matcher))),
    ..old.cases
  ])
}

pub fn build_expression(
  case_: CaseExpression(input, output),
) -> Expression(output) {
  expression.new_case(
    case_.input_expression |> expression.to_unchecked(),
    case_.cases
      |> list.reverse()
      |> list.map(fn(c) {
        fn(context) {
          let rendered_match = matcher.render(c.0)
          let rendered_response = expression.render(c.1, context)
          rendered_match.doc
          |> doc.append(
            doc.concat([doc.space, doc.from_string("->"), doc.space]),
          )
          |> doc.group()
          |> doc.append(rendered_response.doc)
          |> render.Render(details: render.merge_details(
            rendered_match.details,
            rendered_response.details,
          ))
        }
      }),
    case_.cases
      |> list.first()
      |> result.map(fn(c) { expression.type_(c.1) })
      |> result.lazy_unwrap(fn() { types.unchecked() }),
  )
}
