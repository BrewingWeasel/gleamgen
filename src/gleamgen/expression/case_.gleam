import glam/doc
import gleam/bool
import gleam/dict
import gleam/function
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
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
  let matchers_combined = list.group(case_.cases, by: fn(matcher) { matcher.1 })

  let simplified_matchers =
    case_.cases
    |> list.reverse()
    |> list.map_fold(
      from: set.new(),
      with: fn(previously_matched, matcher_details) {
        let #(matcher, output) = matcher_details
        use <- bool.guard(
          when: set.contains(output, in: previously_matched),
          return: #(previously_matched, Error(Nil)),
        )

        let renderer = fn(context) {
          let matcher = case dict.get(matchers_combined, output) {
            Ok([_, _, ..] as repeated_matchers) -> {
              let assert Ok(new_matcher) =
                repeated_matchers
                |> list.map(pair.first)
                |> list.reduce(fn(matcher_1, matcher_2) {
                  matcher.or(
                    matcher_1 |> matcher.to_unchecked(),
                    matcher_2 |> matcher.to_unchecked(),
                  )
                })
              new_matcher
            }
            _ -> matcher
          }
          let rendered_match = matcher.render(matcher)
          let rendered_response = expression.render(output, context)

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
        #(set.insert(previously_matched, output), Ok(renderer))
      },
    )
    |> pair.second()
    |> list.filter_map(function.identity)

  expression.new_case(
    case_.input_expression |> expression.to_unchecked(),
    simplified_matchers,
    case_.cases
      |> list.first()
      |> result.map(fn(c) { expression.type_(c.1) })
      |> result.lazy_unwrap(fn() { types.unchecked() }),
  )
}
