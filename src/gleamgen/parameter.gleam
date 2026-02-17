import glam/doc
import gleam/option
import gleamgen/render
import gleamgen/types

pub opaque type Parameter(type_) {
  Parameter(
    name: String,
    type_: types.GeneratedType(type_),
    label: option.Option(String),
  )
}

pub fn new(name: String, type_: types.GeneratedType(type_)) -> Parameter(type_) {
  Parameter(name:, type_:, label: option.None)
}

pub fn with_label(parameter: Parameter(a), label: String) -> Parameter(a) {
  Parameter(..parameter, label: option.Some(label))
}

pub fn name(parameter: Parameter(a)) -> String {
  parameter.name
}

pub fn type_(parameter: Parameter(type_)) -> types.GeneratedType(type_) {
  parameter.type_
}

pub fn has_label(parameter: Parameter(a)) -> Bool {
  option.is_some(parameter.label)
}

@internal
pub fn render(
  parameter: Parameter(type_),
  include_labels include_labels: Bool,
  context context: render.Context,
) -> doc.Document {
  let label = case parameter.label {
    option.Some(label) if include_labels ->
      doc.concat([doc.from_string(label), doc.space])
    _ -> doc.empty
  }

  let name = doc.from_string(parameter.name)
  let addition = case types.render_type(parameter.type_) {
    Ok(rendered) if context.config.render_function_parameter_types ->
      doc.concat([doc.from_string(":"), doc.space, rendered.doc])
    _ -> doc.empty
  }

  doc.concat([label, name, addition])
}

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_dynamic(_parameter: Parameter(a)) -> Parameter(types.Dynamic)
