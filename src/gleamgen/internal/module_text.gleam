import glance
import gleam/list
import gleam/string

pub type ModuleText {
  ModuleText(content: List(String), location: Int)
}

pub fn take_until(module_text: ModuleText, n: Int) -> #(String, ModuleText) {
  let #(taken, remaining) =
    list.split(module_text.content, n - module_text.location)
  let new_module_text = ModuleText(content: remaining, location: n)

  #(string.join(taken, ""), new_module_text)
}

pub fn from_string(content: String) -> ModuleText {
  ModuleText(content: string.to_graphemes(content), location: 0)
}

pub fn fold(
  input: List(a),
  module_text: ModuleText,
  initial_value: b,
  handler: fn(a, b, String, String) -> b,
  get_span: fn(a) -> glance.Span,
) -> #(b, ModuleText) {
  do_fold(input, initial_value, module_text, handler, get_span)
}

fn do_fold(
  input: List(a),
  acc: b,
  module_text: ModuleText,
  handler: fn(a, b, String, String) -> b,
  get_span: fn(a) -> glance.Span,
) -> #(b, ModuleText) {
  case input {
    [first, ..rest] -> {
      let span = get_span(first)
      let #(before, module_text) = take_until(module_text, span.start)
      let #(main_content, module_text) = take_until(module_text, span.end)

      let result =
        handler(first, acc, trim_leading_newlines(before), main_content)

      do_fold(rest, result, module_text, handler, get_span)
    }
    [] -> #(acc, module_text)
  }
}

fn trim_leading_newlines(input: String) -> String {
  string.to_graphemes(input)
  |> do_trim_leading_newlines(True, True, True, [])
  |> list.drop_while(fn(s) { s == " " || s == "\t" })
  |> list.reverse()
  |> string.join("")
}

fn do_trim_leading_newlines(
  contents,
  line_entirely_whitespace,
  can_add_newline,
  is_first_line,
  acc,
) {
  case contents {
    ["\n", ..rest]
      if line_entirely_whitespace && can_add_newline && !is_first_line
    -> do_trim_leading_newlines(rest, True, False, False, ["\n", ..acc])
    ["\n", ..rest] if line_entirely_whitespace ->
      do_trim_leading_newlines(rest, True, False, can_add_newline, acc)
    ["\t", ..rest] | [" ", ..rest] if line_entirely_whitespace ->
      do_trim_leading_newlines(rest, True, can_add_newline, is_first_line, acc)
    [first, ..rest] ->
      do_trim_leading_newlines(rest, False, can_add_newline, is_first_line, [
        first,
        ..acc
      ])
    [] -> acc
  }
}
