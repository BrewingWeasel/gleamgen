import gleam/io
import gleam/string

const module_used = "Gleamgen"

fn greeter(greeting: String) -> String {
  greeting <> " from " <> module_used
}

pub fn main() -> Nil {
  let greeting = greeter(string.repeat("Hi", 5))
  io.println(greeting)
}
