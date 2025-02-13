# Changelog

## v0.3.5 - 2025-02-12

- added support for automatically combining alternate patterns in case statements

## v0.3.4 - 2025-02-09

- added type.reference

## v0.3.3 - 2025-02-08

- added support for pattern matching in let declarations
- added support for anonymous functions

## v0.3.2 - 2025-01-27

- added support for unchecked matchers
- fixed functions with the same name as keywords in Javascript retaining the `$` in generated gleam code

## v0.3.1 - 2025-01-03

- added support for use expressions
- added missing types.functionN functions

## v0.3.0 - 2024-11-26

- added support for prepending to lists `[x, ..xs]`
- reworked generics for custom types to be more flexible and type-safe
- fix not escaping strings
- add equals expression
- add support for builtin result type
- replace type functions with constants where possible
- do not render imports that are not used in the final generated code
- add support for string concatenation in case expressions

## v0.2.1 - 2024-11-13

- added support for or (|) in case expressions
- added support for as in case expressions
- added support for integer literals in case expressions

## v0.2.0 - 2024-11-11

- renamed decorators to attributes
- add panic expression
- add type aliases
- add missing "with_custom_typeN" functions to module

## v0.1.0 - 2024-11-11

Initial release
