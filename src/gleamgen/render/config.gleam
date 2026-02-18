pub type Config {
  Config(render_function_parameter_types: Bool, auto_fix_parameters: Bool)
}

pub const default_config = Config(
  render_function_parameter_types: True,
  auto_fix_parameters: True,
)
