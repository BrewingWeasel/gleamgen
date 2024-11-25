import gleam/io

const module_used = "Gleamgen"

fn greeter(greeting: String) -> String {
  greeting <> " from " <> module_used
}

pub fn main() -> Nil {
  let greeting = greeter("Howdy")
  io.println(greeting)
}