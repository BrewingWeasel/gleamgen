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
  GeneratedTuple(List(GeneratedType(Unchecked)))
  GeneratedFunction(List(GeneratedType(Unchecked)), GeneratedType(Unchecked))
  Unchecked
  CustomType(String, List(GeneratedType(Unchecked)))
  UncheckedIdent(String)
  Generic(String)
}

pub const bool: GeneratedType(Bool) = GeneratedBool

pub const nil: GeneratedType(Nil) = GeneratedNil

pub const float: GeneratedType(Float) = GeneratedFloat

pub const int: GeneratedType(Int) = GeneratedInt

pub const string: GeneratedType(String) = GeneratedString

pub fn generic(name: String) -> GeneratedType(a) {
  Generic(name)
}

pub fn list(type_: GeneratedType(t)) -> GeneratedType(List(t)) {
  GeneratedList(type_ |> to_unchecked)
}

pub fn tuple1(type1: GeneratedType(a)) -> GeneratedType(#(a)) {
  GeneratedTuple([type1 |> to_unchecked])
}

pub fn tuple2(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
) -> GeneratedType(#(a, b)) {
  GeneratedTuple([type1 |> to_unchecked, type2 |> to_unchecked])
}

pub fn tuple3(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
) -> GeneratedType(#(a, b, c)) {
  GeneratedTuple([
    type1 |> to_unchecked,
    type2 |> to_unchecked,
    type3 |> to_unchecked,
  ])
}

pub fn tuple4(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
  type4: GeneratedType(d),
) -> GeneratedType(#(a, b, c, d)) {
  GeneratedTuple([
    type1 |> to_unchecked,
    type2 |> to_unchecked,
    type3 |> to_unchecked,
    type4 |> to_unchecked,
  ])
}

pub fn tuple5(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
  type4: GeneratedType(d),
  type5: GeneratedType(e),
) -> GeneratedType(#(a, b, c, d, e)) {
  GeneratedTuple([
    type1 |> to_unchecked,
    type2 |> to_unchecked,
    type3 |> to_unchecked,
    type4 |> to_unchecked,
    type5 |> to_unchecked,
  ])
}

pub fn tuple6(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
  type4: GeneratedType(d),
  type5: GeneratedType(e),
  type6: GeneratedType(f),
) -> GeneratedType(#(a, b, c, d, e, f)) {
  GeneratedTuple([
    type1 |> to_unchecked,
    type2 |> to_unchecked,
    type3 |> to_unchecked,
    type4 |> to_unchecked,
    type5 |> to_unchecked,
    type6 |> to_unchecked,
  ])
}

pub fn tuple7(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
  type4: GeneratedType(d),
  type5: GeneratedType(e),
  type6: GeneratedType(f),
  type7: GeneratedType(g),
) -> GeneratedType(#(a, b, c, d, e, f, g)) {
  GeneratedTuple([
    type1 |> to_unchecked,
    type2 |> to_unchecked,
    type3 |> to_unchecked,
    type4 |> to_unchecked,
    type5 |> to_unchecked,
    type6 |> to_unchecked,
    type7 |> to_unchecked,
  ])
}

pub fn tuple8(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
  type4: GeneratedType(d),
  type5: GeneratedType(e),
  type6: GeneratedType(f),
  type7: GeneratedType(g),
  type8: GeneratedType(h),
) -> GeneratedType(#(a, b, c, d, e, f, g, h)) {
  GeneratedTuple([
    type1 |> to_unchecked,
    type2 |> to_unchecked,
    type3 |> to_unchecked,
    type4 |> to_unchecked,
    type5 |> to_unchecked,
    type6 |> to_unchecked,
    type7 |> to_unchecked,
    type8 |> to_unchecked,
  ])
}

pub fn tuple9(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
  type4: GeneratedType(d),
  type5: GeneratedType(e),
  type6: GeneratedType(f),
  type7: GeneratedType(g),
  type8: GeneratedType(h),
  type9: GeneratedType(i),
) -> GeneratedType(#(a, b, c, d, e, f, g, h, i)) {
  GeneratedTuple([
    type1 |> to_unchecked,
    type2 |> to_unchecked,
    type3 |> to_unchecked,
    type4 |> to_unchecked,
    type5 |> to_unchecked,
    type6 |> to_unchecked,
    type7 |> to_unchecked,
    type8 |> to_unchecked,
    type9 |> to_unchecked,
  ])
}

pub fn unchecked_ident(name: String) -> GeneratedType(any) {
  UncheckedIdent(name)
}

pub fn unchecked() -> GeneratedType(any) {
  Unchecked
}

pub fn result(
  ok_type: GeneratedType(ok),
  err_type: GeneratedType(err),
) -> GeneratedType(Result(ok, err)) {
  CustomType("Result", [ok_type |> to_unchecked, err_type |> to_unchecked])
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

@internal
pub fn custom_type(
  name: String,
  types: List(GeneratedType(Unchecked)),
) -> GeneratedType(a) {
  CustomType(name, types)
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
    GeneratedList(t) -> render_custom("List", [t])
    GeneratedTuple(t) -> render_tuple(t)
    CustomType(name, types) -> render_custom(name, types)
    Unchecked -> Error(Nil)
    UncheckedIdent(t) -> doc.from_string(t) |> render.Render |> Ok
    Generic(t) -> doc.from_string(t) |> render.Render |> Ok
    GeneratedFunction(args, return) -> {
      render_function(args, return)
    }
  }
}

fn render_custom(
  name: String,
  types: List(GeneratedType(Unchecked)),
) -> Result(render.Rendered, Nil) {
  let rendered_types =
    types
    |> list.map(fn(t) {
      render_type(t) |> result.map(fn(rendered) { rendered.doc })
    })
    |> result.all()
  use rendered <- result.try(rendered_types)

  doc.from_string(name)
  |> doc.append(render.pretty_list(rendered))
  |> render.Render
  |> Ok
}

fn render_tuple(
  types: List(GeneratedType(Unchecked)),
) -> Result(render.Rendered, Nil) {
  let rendered_types =
    types
    |> list.map(fn(t) {
      render_type(t)
      |> result.map(fn(x) { x.doc })
      |> result.unwrap(doc.from_string("??"))
    })
  doc.from_string("#")
  |> doc.append(render.pretty_list(rendered_types))
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
