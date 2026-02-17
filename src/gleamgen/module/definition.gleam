import glam/doc
import glance
import gleam/result
import gleamgen/internal/render

pub type Attribute {
  External(target: Target, module_name: String, function_name: String)
  Deprecated(String)
  Internal
}

pub type Target {
  Erlang
  Javascript
}

pub type Definition {
  Definition(
    name: String,
    is_public: Bool,
    attributes: List(Attribute),
    position: Position,
    text_before: String,
    predefined: Bool,
  )
}

pub type Position {
  Bottom
  Top
  AfterDefinition(definition: String)
}

pub fn new(name name: String) -> Definition {
  Definition(
    name: name,
    is_public: False,
    attributes: [],
    position: Bottom,
    text_before: "",
    predefined: False,
  )
}

pub fn with_publicity(definition: Definition, to is_public: Bool) -> Definition {
  Definition(..definition, is_public:)
}

pub fn with_attributes(
  definition: Definition,
  to attributes: List(Attribute),
) -> Definition {
  Definition(..definition, attributes:)
}

pub fn with_position(
  definition: Definition,
  at position: Position,
) -> Definition {
  Definition(..definition, position:)
}

@internal
pub fn with_text_before(
  definition: Definition,
  text_before: String,
) -> Definition {
  Definition(..definition, text_before:)
}

@internal
pub fn set_predefined(definition: Definition, predefined: Bool) -> Definition {
  Definition(..definition, predefined:)
}

pub fn render_attribute(attribute: Attribute) -> doc.Document {
  case attribute {
    External(target:, module_name:, function_name:) -> {
      let target_str = case target {
        Erlang -> "erlang"
        Javascript -> "javascript"
      }
      let to_str = fn(s) { doc.from_string("\"" <> s <> "\"") }
      doc.concat([
        doc.from_string("@external("),
        doc.from_string(target_str),
        doc.from_string(", "),
        to_str(module_name),
        doc.from_string(", "),
        to_str(function_name),
        doc.from_string(")"),
      ])
    }
    Deprecated(reason) ->
      doc.concat([
        doc.from_string("@deprecated(\""),
        doc.from_string(reason),
        doc.from_string("\")"),
      ])
    Internal -> doc.from_string("@internal")
  }
}

@internal
pub fn attribute_from_glance(attribute: glance.Attribute) {
  let glance_expr_to_string = fn(expr) {
    case expr {
      glance.String(value:, ..) -> Ok(render.escape_string(value))
      glance.Variable(name:, ..) -> Ok(name)
      _ -> Error(Nil)
    }
  }
  case attribute {
    glance.Attribute(name: "external", arguments: [target, module, definition]) -> {
      let parsed_target = case glance_expr_to_string(target) {
        Ok("erlang") -> Ok(Erlang)
        Ok("javascript") -> Ok(Javascript)
        _ -> Error(Nil)
      }
      use target <- result.try(parsed_target)
      use module <- result.try(glance_expr_to_string(module))
      use definition <- result.try(glance_expr_to_string(definition))

      Ok(External(target, module, definition))
    }
    glance.Attribute(name: "internal", arguments: []) -> Ok(Internal)
    glance.Attribute(name: "deprecated", arguments: [reason]) ->
      result.map(glance_expr_to_string(reason), Deprecated)
    _ -> Error(Nil)
  }
}
