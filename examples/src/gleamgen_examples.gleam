import examples/create_list_of_all_examples
import generated/create_list_of_all_examples as all_examples
import gleam/io
import gleam/list
import simplifile

pub fn main() {
  let _ = simplifile.create_directory("src/generated")

  let _ =
    create_list_of_all_examples.generate()
    |> simplifile.write(to: "src/generated/create_list_of_all_examples.gleam")
  let examples = all_examples.get_all_examples()

  examples
  |> list.each(fn(example) {
    let #(code, name) = example
    simplifile.write("src/generated/" <> name <> ".gleam", code())
  })

  io.println("Generated examples!")
}
