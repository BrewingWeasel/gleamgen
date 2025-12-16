import glam/doc

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
  )
}

pub type Position {
  Bottom
  Top
  AfterDefinition(definition: String)
}

pub fn new(name: String) -> Definition {
  Definition(name: name, is_public: False, attributes: [], position: Bottom)
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
