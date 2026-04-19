pub type Config {
  Config(
    /// Include explicit type annotations for function parameters when possible.
    render_function_parameter_types: Bool,
    /// Merge `case` branches that produce equivalent outputs.
    combine_equivalent_branches: Bool,
    /// Automatically add missing parameters to function definitions and calls
    auto_fix_parameters: Bool,
    /// Simplify expressions where an anonymous function is immediately called.
    inline_instantly_called_anonymous_functions: Bool,
    /// Include explicit type annotations on `let` bindings.
    annotate_type_in_let_declarations: Bool,
  )
}

/// Recommended defaults for rendering.
pub const default_config = Config(
  render_function_parameter_types: True,
  combine_equivalent_branches: True,
  auto_fix_parameters: True,
  inline_instantly_called_anonymous_functions: True,
  annotate_type_in_let_declarations: False,
)
