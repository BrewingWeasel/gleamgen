import gleam/dict
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
