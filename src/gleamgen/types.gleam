import glam/doc
import gleam/list
import gleam/result
import gleamgen/render

pub type Unchecked

pub opaque type GeneratedType(type_) {
  GeneratedBool
  GeneratedString
  GeneratedInt
  GeneratedFloat
  GeneratedNil
  GeneratedList(GeneratedType(Unchecked))
  GeneratedFunction(List(GeneratedType(Unchecked)), GeneratedType(Unchecked))
  Unchecked
  UncheckedIdent(String)
}

pub fn bool() -> GeneratedType(Bool) {
  GeneratedBool
}

pub fn string() -> GeneratedType(String) {
  GeneratedString
}

pub fn int() -> GeneratedType(Int) {
  GeneratedInt
}

pub fn float() -> GeneratedType(Float) {
  GeneratedFloat
}

pub fn nil() -> GeneratedType(Nil) {
  GeneratedNil
}

pub fn list(type_: GeneratedType(t)) -> GeneratedType(List(t)) {
  GeneratedList(type_ |> to_unchecked)
}

pub fn unchecked_ident(name: String) -> GeneratedType(any) {
  UncheckedIdent(name)
}

pub fn unchecked() -> GeneratedType(any) {
  Unchecked
}

pub fn function0(returns: GeneratedType(ret)) -> GeneratedType(fn() -> ret) {
  GeneratedFunction([], returns |> to_unchecked)
}

pub fn function1(
  arg1: GeneratedType(arg1),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1) -> ret) {
  GeneratedFunction([arg1 |> to_unchecked], returns |> to_unchecked)
}

pub fn function2(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1, arg2) -> ret) {
  GeneratedFunction(
    [arg1 |> to_unchecked, arg2 |> to_unchecked],
    returns |> to_unchecked,
  )
}

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_unchecked(type_: GeneratedType(t)) -> GeneratedType(Unchecked)

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn unsafe_from_unchecked(
  type_: GeneratedType(Unchecked),
) -> GeneratedType(a)

pub fn render_type(type_: GeneratedType(a)) -> Result(render.Rendered, Nil) {
  case type_ {
    GeneratedBool -> doc.from_string("Bool") |> render.Render |> Ok
    GeneratedString -> doc.from_string("String") |> render.Render |> Ok
    GeneratedInt -> doc.from_string("Int") |> render.Render |> Ok
    GeneratedFloat -> doc.from_string("Float") |> render.Render |> Ok
    GeneratedNil -> doc.from_string("Nil") |> render.Render |> Ok
    GeneratedList(t) -> render_list(t)
    Unchecked -> Error(Nil)
    UncheckedIdent(t) -> doc.from_string(t) |> render.Render |> Ok
    GeneratedFunction(args, return) -> {
      render_function(args, return)
    }
  }
}

fn render_list(type_: GeneratedType(Unchecked)) -> Result(render.Rendered, Nil) {
  use rendered <- result.try(render_type(type_))
  doc.from_string("List")
  |> doc.append(render.pretty_list([rendered.doc]))
  |> render.Render
  |> Ok
}

fn render_function(args, return) {
  use args <- result.try(list.try_map(args, render_type))
  let return = render_type(return)
  doc.concat([
    doc.from_string("fn"),
    render.pretty_list(list.map(args, fn(v) { v.doc })),
    doc.space,
    case return {
      Ok(ret) -> doc.concat([doc.from_string("->"), doc.space, ret.doc])
      Error(_) -> doc.empty
    },
  ])
  |> render.Render
  |> Ok
}
