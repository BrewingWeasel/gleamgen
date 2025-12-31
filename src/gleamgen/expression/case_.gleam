import glam/doc
import gleam/bool
import gleam/dict
import gleam/function
import gleam/list
import gleam/pair
import gleam/result
import gleam/set
import gleamgen/expression.{type Expression}
import gleamgen/pattern.{type Pattern}
import gleamgen/render
import gleamgen/types.{type Unchecked}

pub type CaseExpression(input, output) {
  CaseExpression(
    input_expression: Expression(input),
    cases: List(#(Pattern(Unchecked, Unchecked), Expression(output))),
  )
}

/// Create a new case expression that matches on the given input_expression
///
/// ```gleam
/// case_.new(expression.string("hello"))
/// |> case_.with_pattern(pattern.string_literal("hello"), fn(_) {
///   expression.string("world")
/// })
/// |> case_.with_pattern(pattern.variable("v"), fn(v) {
///   expression.concat_string(v, expression.string(" world"))
/// })
/// |> case_.build_expression()
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// ```
///
/// This creates:
/// ```gleam
/// case "hello" {
///   "hello" -> "world"
///   v -> v <> " world"
/// }
/// ```
/// Note that providing a tuple literal as the case subject will expand into multiple subjects:
///
/// ```gleam
/// case_.new(expression.tuple2(expression.string("hello"), expression.int(3)))
/// |> case_.with_pattern(
///   pattern.tuple2(pattern.string_literal("hello"), pattern.variable("_")),
///   fn(_) { expression.string("world") },
/// )
/// |> case_.with_pattern(pattern.variable("_"), fn(_) {
///   expression.string("other")
/// })
/// |> case_.build_expression()
/// |> expression.render(render.default_context())
/// |> render.to_string()
/// ```
///
/// This creates:
/// ```gleam
/// case "hello", 3 {
///   "hello", _ -> "world"
///   _, _ -> "other"
/// }
/// ```
pub fn new(input_expression: Expression(input)) -> CaseExpression(input, a) {
  CaseExpression(input_expression, [])
}

pub fn with_pattern(
  old: CaseExpression(input, output),
  pattern: Pattern(input, pattern_output),
  handler: fn(pattern_output) -> Expression(output),
) {
  CaseExpression(old.input_expression, [
    #(pattern |> pattern.to_unchecked(), handler(pattern.get_output(pattern))),
    ..old.cases
  ])
}

pub fn build_expression(
  case_: CaseExpression(input, output),
) -> Expression(output) {
  let patterns_combined = list.group(case_.cases, by: fn(pattern) { pattern.1 })

  let simplified_patterns =
    case_.cases
    |> list.reverse()
    |> list.map_fold(
      from: set.new(),
      with: fn(previously_matched, pattern_details) {
        let #(pattern, output) = pattern_details
        use <- bool.guard(
          when: set.contains(output, in: previously_matched),
          return: #(previously_matched, Error(Nil)),
        )

        let renderer = fn(context, number_of_subjects) {
          let pattern = case dict.get(patterns_combined, output) {
            Ok([_, _, ..] as repeated_patterns) -> {
              let assert Ok(new_pattern) =
                repeated_patterns
                |> list.map(pair.first)
                |> list.reduce(fn(pattern_1, pattern_2) {
                  pattern.or(
                    pattern_1 |> pattern.to_unchecked(),
                    pattern_2 |> pattern.to_unchecked(),
                  )
                })
              new_pattern
            }
            _ -> pattern
          }
          let rendered_match = pattern.render(pattern, number_of_subjects)
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

  let all_can_match_on_multiple =
    list.all(case_.cases, fn(m) { pattern.can_match_on_multiple(m.0) })

  expression.new_case(
    case_.input_expression |> expression.to_unchecked(),
    simplified_patterns,
    all_can_match_on_multiple,
    case_.cases
      |> list.first()
      |> result.map(fn(c) { expression.type_(c.1) })
      |> result.lazy_unwrap(fn() { types.unchecked() }),
  )
}
