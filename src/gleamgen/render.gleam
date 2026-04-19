import gleamgen/internal/render
import gleamgen/render/report

/// The rendered output and metadata produced by `module.render`,
/// `expression.render`, and similar APIs.
pub type Rendered =
  render.Rendered

/// Extra information gathered while rendering, including warnings,
/// errors, and import usage.
pub type RenderedDetails =
  render.RenderedDetails

/// Rendering context that controls formatting and rendering behavior.
///
/// To create a context, use [`default_context`](#default_context) or [`context_from_config`](#context_from_config).
pub type Context =
  render.Context

/// Convert a rendered document into source code.
pub const to_string = render.to_string

/// Use the default configuration.
///
/// See also [`context_from_config`](#context_from_config)
pub const default_context = render.default_context

/// Create a context from a custom configuration
pub const context_from_config = render.context_from_config

/// Merge metadata from two rendered values.
/// This is useful when manually combining multiple rendered fragments.
pub const merge_details = render.merge_details

/// Extract rendering diagnostics from a rendered value.
pub fn get_report(rendered: Rendered) -> report.Report {
  rendered.details.report
}
