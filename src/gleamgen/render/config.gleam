pub type Config {
  Config(
    render_function_parameter_types: Bool,
    combine_equivalent_branches: Bool,
    auto_fix_parameters: Bool,
  )
}

pub const default_config = Config(
  render_function_parameter_types: True,
  combine_equivalent_branches: True,
  auto_fix_parameters: True,
)
