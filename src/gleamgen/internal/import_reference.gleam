import glam/doc
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
) -> doc.Document {
  case imported.alias {
    option.Some(alias) -> {
      case dict.get(imported.unqualified_values, item_name) {
        Ok(alias_name) -> doc.from_string(alias_name)
        Error(_) -> doc.from_string(alias <> "." <> item_name)
      }
    }
    option.None -> {
      let assert Ok(name) = imported.module |> list.last
      case dict.get(imported.unqualified_values, item_name) {
        Ok(alias_name) -> doc.from_string(alias_name)
        Error(Nil) -> doc.from_string(name <> "." <> item_name)
      }
    }
  }
}

pub fn new_implied_reference(name: List(String)) -> ImportReference {
  ImportReference(
    module: name,
    alias: option.None,
    implied: True,
    unqualified_values: dict.new(),
  )
}
