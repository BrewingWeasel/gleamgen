import gleamgen/internal/render
import gleamgen/render/report

pub type Rendered =
  render.Rendered

pub type RenderedDetails =
  render.RenderedDetails

pub type Context =
  render.Context

pub const to_string = render.to_string

/// Use the default configuration
/// See also `context_from_config`
pub const default_context = render.default_context

/// Create a context from a custom configuration
pub const context_from_config = render.context_from_config

pub const merge_details = render.merge_details

pub fn get_report(rendered: Rendered) -> report.Report {
  rendered.details.report
}
