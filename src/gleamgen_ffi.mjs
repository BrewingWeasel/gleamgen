import { Ok, Error } from "./gleam.mjs";

export function identity(x) {
  return x;
}

export function get_function_name(x) {
  const name = x.name;
  const final_char = name.length - 1;
  if (name.charAt(final_char) == "$") {
    return name.substring(0, final_char);
  } else {
    return x.name;
  }
}

export function get_matcher_output(x) {
  if (x.output) {
    return new Ok(x.output);
  } else {
    return new Error(undefined);
  }
}
