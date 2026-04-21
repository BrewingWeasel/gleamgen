import glam/doc
import gleam/bool
import gleam/dict
import gleam/function
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/set
import gleamgen/expression.{type Expression}
import gleamgen/internal/render
import gleamgen/pattern.{type Pattern}
import gleamgen/type_.{type Dynamic}

pub opaque type CaseExpression(input, output) {
  CaseExpression(
    input_expression: Expression(input),
    clauses: List(Clause(output)),
  )
}

type Clause(output) {
  Clause(
    pattern: Pattern(Dynamic, Dynamic),
    guard: option.Option(Expression(Bool)),
    handler: Expression(output),
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
    Clause(
      pattern |> pattern.to_dynamic(),
      option.None,
      handler(pattern.get_output(pattern)),
    ),
    ..old.clauses
  ])
}

pub fn with_pattern_guarded(
  old: CaseExpression(input, output),
  pattern: Pattern(input, pattern_output),
  guard: Expression(Bool),
  handler: fn(pattern_output) -> Expression(output),
) {
  CaseExpression(old.input_expression, [
    Clause(
      pattern |> pattern.to_dynamic(),
      option.Some(guard),
      handler(pattern.get_output(pattern)),
    ),
    ..old.clauses
  ])
}

pub fn build_expression(
  case_: CaseExpression(input, output),
) -> Expression(output) {
  let create_patterns = fn(context: render.Context) {
    let patterns_combined = case context.config.combine_equivalent_branches {
      True ->
        list.group(case_.clauses, by: fn(clause) {
          #(clause.handler, clause.guard)
        })
      False ->
        case_.clauses
        |> list.map(fn(clause) { #(#(clause.handler, clause.guard), [clause]) })
        |> dict.from_list()
    }

    case_.clauses
    |> list.reverse()
    |> list.map_fold(from: set.new(), with: fn(previously_matched, clause) {
      use <- bool.guard(
        when: set.contains(clause.handler, in: previously_matched)
          && context.config.combine_equivalent_branches,
        return: #(previously_matched, Error(Nil)),
      )

      let renderer = fn(number_of_subjects) {
        let pattern = case
          dict.get(patterns_combined, #(clause.handler, clause.guard))
        {
          Ok([_, _, ..] as repeated_patterns) -> {
            let assert Ok(new_pattern) =
              repeated_patterns
              |> list.map(fn(clause) { clause.pattern })
              |> list.reduce(fn(pattern_1, pattern_2) {
                pattern.or(
                  pattern_1 |> pattern.to_dynamic(),
                  pattern_2 |> pattern.to_dynamic(),
                )
              })
            new_pattern
          }
          _ -> clause.pattern
        }
        let rendered_match =
          pattern.render(pattern, context, number_of_subjects)
        let rendered_response = expression.render(clause.handler, context)

        let rendered_guard = case clause.guard {
          option.Some(guard) -> {
            let rendered_guard = expression.render(guard, context)
            doc.concat([
              doc.space,
              doc.from_string("if"),
              doc.space,
              rendered_guard.doc,
            ])
          }
          option.None -> doc.empty
        }

        rendered_match.doc
        |> doc.append(rendered_guard)
        |> doc.append(doc.concat([doc.space, doc.from_string("->"), doc.space]))
        |> doc.group()
        |> doc.append(rendered_response.doc)
        |> render.Render(details: render.merge_details(
          rendered_match.details,
          rendered_response.details,
        ))
      }
      #(set.insert(previously_matched, clause.handler), Ok(renderer))
    })
    |> pair.second()
    |> list.filter_map(function.identity)
  }

  let all_can_match_on_multiple =
    list.all(case_.clauses, fn(clause) {
      pattern.can_match_on_multiple(clause.pattern)
    })

  expression.new_case(
    case_.input_expression |> expression.to_dynamic(),
    create_patterns,
    all_can_match_on_multiple,
    case_.clauses
      |> list.first()
      |> result.map(fn(c) { expression.type_(c.handler) })
      |> result.lazy_unwrap(fn() { type_.dynamic() }),
  )
}
