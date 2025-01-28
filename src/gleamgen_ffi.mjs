import { Ok, Error } from "./gleam.mjs";

export function identity(x) {
  return x;
}

export function get_function_name(x) {
  return x.name;
}

export function get_matcher_output(x) {
  if (x.output) {
    return new Ok(x.output);
  } else {
    return new Error(undefined);
  }
}
