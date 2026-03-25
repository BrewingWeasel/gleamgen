import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleamgen/internal/render
import gleamgen/render/report
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
      doc.concat([doc.from_string(label), doc.from_string(" ")])
    _ -> doc.empty
  }

  let name = doc.from_string(parameter.name)
  let addition = case types.render_type(parameter.type_) {
    Ok(rendered) if context.config.render_function_parameter_types ->
      doc.concat([doc.from_string(":"), doc.from_string(" "), rendered.doc])
    _ -> doc.empty
  }

  doc.concat([label, name, addition])
}

@internal
pub fn render_parameters(
  parameters: List(Parameter(types.Dynamic)),
  include_labels include_labels: Bool,
  context context: render.Context,
) {
  do_render_parameters(
    parameters,
    [],
    False,
    [],
    render.empty_details,
    include_labels,
    context,
  )
}

fn parameter_type_details(
  param: Parameter(types.Dynamic),
) -> render.RenderedDetails {
  types.render_type(type_(param))
  |> result.map(fn(r) { r.details })
  |> result.unwrap(render.empty_details)
}

fn do_render_parameters(
  parameters: List(Parameter(types.Dynamic)),
  acc: List(doc.Document),
  last_parameter_had_label: Bool,
  should_have_been_labeled_params: List(String),
  type_details_acc: render.RenderedDetails,
  include_labels include_labels: Bool,
  context context: render.Context,
) -> render.Rendered {
  case parameters {
    [] -> {
      let doc = render.pretty_list(list.reverse(acc))

      let label_details = case should_have_been_labeled_params {
        [] -> render.empty_details
        not_labeled if context.config.auto_fix_parameters -> {
          render.RenderedDetails(
            ..render.empty_details,
            report: report.Report(
              warnings: [
                report.AutomaticallyAddedMissingLabels(list.reverse(not_labeled)),
              ],
              errors: [],
            ),
          )
        }
        not_labeled -> {
          render.RenderedDetails(
            ..render.empty_details,
            report: report.Report(warnings: [], errors: [
              report.MissingLabels(list.reverse(not_labeled)),
            ]),
          )
        }
      }

      let details = render.merge_details(type_details_acc, label_details)

      render.Render(doc, details)
    }
    [param, ..rest] -> {
      let has_label = option.is_some(param.label)
      let next_type_details =
        render.merge_details(type_details_acc, parameter_type_details(param))
      case has_label {
        True ->
          do_render_parameters(
            rest,
            [render(param, include_labels, context), ..acc],
            True,
            should_have_been_labeled_params,
            next_type_details,
            include_labels,
            context,
          )
        False if last_parameter_had_label -> {
          let fixed_parameter = case context.config.auto_fix_parameters {
            True -> with_label(param, param.name)
            False -> param
          }
          let merged_details =
            render.merge_details(
              type_details_acc,
              parameter_type_details(fixed_parameter),
            )
          do_render_parameters(
            rest,
            [render(fixed_parameter, include_labels, context), ..acc],
            True,
            [param.name, ..should_have_been_labeled_params],
            merged_details,
            include_labels,
            context,
          )
        }
        False ->
          do_render_parameters(
            rest,
            [render(param, include_labels, context), ..acc],
            last_parameter_had_label,
            should_have_been_labeled_params,
            next_type_details,
            include_labels,
            context,
          )
      }
    }
  }
}

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_dynamic(_parameter: Parameter(a)) -> Parameter(types.Dynamic)
