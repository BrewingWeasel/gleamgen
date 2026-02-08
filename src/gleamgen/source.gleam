import glam/doc
import glance
import gleam/list
import gleam/result
import gleam/string

pub type SourceMapped(a) {
  SourceMapped(contents: a, source: Source)
}

pub type Source {
  Source(content: List(String), location: Int)
}

@internal
pub fn get_source_map_doc(source_map: SourceMapped(a)) -> doc.Document {
  let #(content, lines_removed) =
    source_map.source.content |> string.join("") |> trim_leading_newlines()
  case lines_removed {
    0 -> doc.from_string(content)
    _ -> doc.append(doc.line, doc.from_string(content))
  }
}

pub fn module_from_string(
  input: String,
) -> Result(SourceMapped(glance.Module), glance.Error) {
  use module <- result.try(glance.module(input))
  Ok(SourceMapped(
    contents: module,
    source: Source(string.to_graphemes(input), 0),
  ))
}

fn drop_until(source: Source, pos: Int) -> Source {
  Source(
    content: list.drop(source.content, pos - source.location),
    location: pos,
  )
}

fn drop_until_character(source: Source, character: String) -> Source {
  case source.content {
    [first, ..rest] if first != character -> {
      drop_until_character(
        Source(content: rest, location: source.location + 1),
        character,
      )
    }
    [first, ..rest] if first == character ->
      Source(content: rest, location: source.location + 1)
    _ -> source
  }
}

@internal
pub fn take_until(source: Source, n: Int) -> #(String, Source) {
  let #(taken, remaining) = list.split(source.content, n - source.location)
  let new_source = Source(content: remaining, location: n)

  #(string.join(taken, ""), new_source)
}

fn end_source_at(source: Source, n: Int) -> Source {
  Source(..source, content: list.take(source.content, n - source.location))
}

@internal
pub fn fold(
  input: List(a),
  module_text: Source,
  initial_value: b,
  handler: fn(a, b, String, String, Source) -> b,
  get_span: fn(a) -> glance.Span,
) -> #(b, Source) {
  do_fold(input, initial_value, module_text, handler, get_span)
}

fn do_fold(
  input: List(a),
  acc: b,
  source: Source,
  handler: fn(a, b, String, String, Source) -> b,
  get_span: fn(a) -> glance.Span,
) -> #(b, Source) {
  case input {
    [first, ..rest] -> {
      let span = get_span(first)
      let #(before, before_source) = take_until(source, span.start)
      let #(main_content, remaining_source) =
        take_until(before_source, span.end)

      let span_source = end_source_at(source, span.end)

      let #(trimmed, _trimmed_lines) = trim_leading_newlines(before)

      let result = handler(first, acc, trimmed, main_content, span_source)

      do_fold(rest, result, remaining_source, handler, get_span)
    }
    [] -> #(acc, source)
  }
}

fn trim_leading_newlines(input: String) -> #(String, Int) {
  let #(trimmed, lines_removed) =
    string.to_graphemes(input)
    |> do_trim_leading_newlines(True, True, 0, [])

  let trimmed_string =
    trimmed
    |> list.drop_while(fn(s) { s == " " || s == "\t" })
    |> list.reverse()
    |> string.join("")

  #(trimmed_string, lines_removed)
}

fn do_trim_leading_newlines(
  contents,
  line_entirely_whitespace,
  is_first_line,
  lines_removed,
  acc,
) {
  case contents {
    // The first newline found corresponds to the last line, so ignore it
    ["\n", ..rest] if line_entirely_whitespace && is_first_line ->
      do_trim_leading_newlines(rest, True, False, lines_removed, acc)

    ["\n", ..rest] if line_entirely_whitespace ->
      do_trim_leading_newlines(rest, True, False, lines_removed + 1, acc)

    ["\t", ..rest] | [" ", ..rest] if line_entirely_whitespace ->
      do_trim_leading_newlines(rest, True, is_first_line, lines_removed, acc)

    [first, ..rest] ->
      do_trim_leading_newlines(rest, False, is_first_line, lines_removed, [
        first,
        ..acc
      ])
    [] -> #(acc, lines_removed)
  }
}

pub fn get_function_body(
  function: SourceMapped(glance.Function),
) -> List(SourceMapped(glance.Statement)) {
  let span = function.contents.location
  let source =
    function.source
    |> drop_until(span.start)
    |> drop_until_character("{")

  let #(statements, _source) =
    fold(
      function.contents.body,
      source,
      [],
      fn(statement, acc, _, _, source) {
        [SourceMapped(contents: statement, source:), ..acc]
      },
      fn(s) {
        case s {
          glance.Expression(e) -> e.location
          glance.Use(location:, ..)
          | glance.Assignment(location:, ..)
          | glance.Assert(location:, ..) -> location
        }
      },
    )

  list.reverse(statements)
}
