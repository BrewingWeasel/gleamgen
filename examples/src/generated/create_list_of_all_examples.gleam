import examples/create_list_of_all_examples
import examples/hello_world
import examples/unchecked_custom_types

pub fn get_all_examples() -> List(#(fn() -> String, String)) {
  [
    #(hello_world.generate, "hello_world"),
    #(create_list_of_all_examples.generate, "create_list_of_all_examples"),
    #(unchecked_custom_types.generate, "unchecked_custom_types"),
  ]
}