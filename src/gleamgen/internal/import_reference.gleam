import gleam/dict
import gleam/list
import gleam/option

type Alias =
  String

type Value =
  String

pub type ImportReference {
  ImportReference(
    module: List(String),
    alias: option.Option(String),
    implied: Bool,
    unqualified_values: dict.Dict(Value, Alias),
  )
}

pub fn get_module_representation(imported: ImportReference) -> String {
  case imported.alias {
    option.Some(alias) -> alias
    option.None ->
      case list.last(imported.module) {
        Ok(name) -> name
        Error(_) -> ""
      }
  }
}

pub fn get_reference(
  imported: ImportReference,
  item_name: String,
) -> #(option.Option(String), String) {
  case imported.alias {
    option.Some(alias) -> {
      case dict.get(imported.unqualified_values, item_name) {
        Ok(alias_name) -> #(option.None, alias_name)
        Error(_) -> #(option.Some(alias), item_name)
      }
    }
    option.None -> {
      let assert Ok(name) = imported.module |> list.last
      case dict.get(imported.unqualified_values, item_name) {
        Ok(alias_name) -> #(option.None, alias_name)
        Error(Nil) -> #(option.Some(name), item_name)
      }
    }
  }
}
