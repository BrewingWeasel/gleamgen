import gleam/io

pub const greeting = "hello"

fn greet_user(user: String) -> String {
  greeting <> " " <> user
}

pub fn main() -> Nil {
  let name = "Viktor"
  // A greeting for the given name
  let greeting = greet_user(name)

  io.println(greeting)
}