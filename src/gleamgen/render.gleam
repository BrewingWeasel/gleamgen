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
  doc.to_string(to_render.doc, 80)
}

@internal
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

@internal
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

@internal
pub fn escape_string(string: String) -> doc.Document {
  let escaped = do_escape_string(string, "")
  doc.concat([
    doc.from_string("\""),
    doc.from_string(escaped),
    doc.from_string("\""),
  ])
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
