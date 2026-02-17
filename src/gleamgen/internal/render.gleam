import glam/doc
import gleam/list
import gleam/string

pub type Rendered {
  Render(doc: doc.Document, details: RenderedDetails)
}

pub type RenderedDetails {
  RenderedDetails(used_imports: List(String))
}

pub const empty_details = RenderedDetails([])

pub fn merge_details(
  first: RenderedDetails,
  second: RenderedDetails,
) -> RenderedDetails {
  RenderedDetails(list.append(first.used_imports, second.used_imports))
}

pub type Context {
  Context(render_types: Bool, include_brackets_current_level: Bool)
}

pub fn default_context() -> Context {
  Context(True, True)
}

pub fn to_string(to_render: Rendered) -> String {
  to_render.doc |> doc.to_string(80) |> post_process()
}

pub fn pretty_list(parameters: List(doc.Document)) -> doc.Document {
  let comma = doc.concat([doc.from_string(","), doc.space])
  let trailing_comma = doc.break("", ",")

  let open_paren = doc.concat([doc.from_string("("), doc.soft_break])
  let close_paren = doc.concat([trailing_comma, doc.from_string(")")])

  parameters
  |> doc.join(with: comma)
  |> doc.prepend(open_paren)
  |> doc.nest(2)
  |> doc.append(close_paren)
  |> doc.group
}

pub fn body(
  inside: doc.Document,
  force_newlines force_break: Bool,
) -> doc.Document {
  let between_brackets = case force_break {
    True -> doc.line
    False -> doc.space
  }

  inside
  |> doc.prepend(doc.concat([doc.from_string("{"), between_brackets]))
  |> doc.nest(2)
  |> doc.append(doc.concat([between_brackets, doc.from_string("}")]))
  |> doc.group
}

pub fn escape_string(string: String) -> String {
  let escaped = do_escape_string(string, "")
  "\"" <> escaped <> "\""
}

fn do_escape_string(original: String, escaped: String) -> String {
  case string.pop_grapheme(original) {
    Ok(#("\"", rest)) -> {
      do_escape_string(rest, escaped <> "\\\"")
    }
    Ok(#(c, rest)) -> {
      do_escape_string(rest, escaped <> c)
    }
    Error(Nil) -> escaped
  }
}

fn post_process(string: String) -> String {
  string
  |> string.to_graphemes()
  |> remove_space_newlines([], [])
  |> list.reverse()
  |> string.join("")
}

fn remove_space_newlines(
  graphemes: List(String),
  line_starting_spaces: List(String),
  acc: List(String),
) -> List(String) {
  case graphemes {
    ["\n", ..rest] -> remove_space_newlines(rest, [], ["\n", ..acc])
    [" " as space, ..rest] | ["\t" as space, ..rest] ->
      remove_space_newlines(rest, [space, ..line_starting_spaces], acc)

    [first, ..rest] if line_starting_spaces != [] ->
      remove_space_newlines(
        rest,
        [],
        list.append([first, ..line_starting_spaces], acc),
      )
    [first, ..rest] -> remove_space_newlines(rest, [], [first, ..acc])
    [] -> acc
  }
}
