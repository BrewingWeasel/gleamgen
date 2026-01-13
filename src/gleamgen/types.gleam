import glam/doc
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import gleamgen/render

pub type Dynamic

pub opaque type GeneratedType(type_) {
  GeneratedBool
  GeneratedString
  GeneratedInt
  GeneratedFloat
  GeneratedNil
  GeneratedList(GeneratedType(Dynamic))
  GeneratedTuple(List(GeneratedType(Dynamic)))
  GeneratedFunction(List(GeneratedType(Dynamic)), GeneratedType(Dynamic))
  Dynamic
  CustomType(option.Option(String), String, List(GeneratedType(Dynamic)))
  Raw(String)
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
  GeneratedList(type_ |> to_dynamic)
}

pub fn tuple1(type1: GeneratedType(a)) -> GeneratedType(#(a)) {
  GeneratedTuple([type1 |> to_dynamic])
}

pub fn tuple2(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
) -> GeneratedType(#(a, b)) {
  GeneratedTuple([type1 |> to_dynamic, type2 |> to_dynamic])
}

pub fn tuple3(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
) -> GeneratedType(#(a, b, c)) {
  GeneratedTuple([
    type1 |> to_dynamic,
    type2 |> to_dynamic,
    type3 |> to_dynamic,
  ])
}

pub fn tuple4(
  type1: GeneratedType(a),
  type2: GeneratedType(b),
  type3: GeneratedType(c),
  type4: GeneratedType(d),
) -> GeneratedType(#(a, b, c, d)) {
  GeneratedTuple([
    type1 |> to_dynamic,
    type2 |> to_dynamic,
    type3 |> to_dynamic,
    type4 |> to_dynamic,
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
    type1 |> to_dynamic,
    type2 |> to_dynamic,
    type3 |> to_dynamic,
    type4 |> to_dynamic,
    type5 |> to_dynamic,
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
    type1 |> to_dynamic,
    type2 |> to_dynamic,
    type3 |> to_dynamic,
    type4 |> to_dynamic,
    type5 |> to_dynamic,
    type6 |> to_dynamic,
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
    type1 |> to_dynamic,
    type2 |> to_dynamic,
    type3 |> to_dynamic,
    type4 |> to_dynamic,
    type5 |> to_dynamic,
    type6 |> to_dynamic,
    type7 |> to_dynamic,
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
    type1 |> to_dynamic,
    type2 |> to_dynamic,
    type3 |> to_dynamic,
    type4 |> to_dynamic,
    type5 |> to_dynamic,
    type6 |> to_dynamic,
    type7 |> to_dynamic,
    type8 |> to_dynamic,
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
    type1 |> to_dynamic,
    type2 |> to_dynamic,
    type3 |> to_dynamic,
    type4 |> to_dynamic,
    type5 |> to_dynamic,
    type6 |> to_dynamic,
    type7 |> to_dynamic,
    type8 |> to_dynamic,
    type9 |> to_dynamic,
  ])
}

pub fn raw(name: String) -> GeneratedType(any) {
  Raw(name)
}

pub fn dynamic() -> GeneratedType(any) {
  Dynamic
}

pub fn reference(_: a) -> GeneratedType(a) {
  Dynamic
}

pub fn result(
  ok_type: GeneratedType(ok),
  err_type: GeneratedType(err),
) -> GeneratedType(Result(ok, err)) {
  CustomType(option.None, "Result", [
    ok_type |> to_dynamic,
    err_type |> to_dynamic,
  ])
}

pub fn function0(returns: GeneratedType(ret)) -> GeneratedType(fn() -> ret) {
  GeneratedFunction([], returns |> to_dynamic)
}

pub fn dynamic_function(
  args: List(GeneratedType(Dynamic)),
  returns: GeneratedType(Dynamic),
) -> GeneratedType(Dynamic) {
  GeneratedFunction(args, returns)
}

pub fn function1(
  arg1: GeneratedType(arg1),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1) -> ret) {
  GeneratedFunction([arg1 |> to_dynamic], returns |> to_dynamic)
}

pub fn function2(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1, arg2) -> ret) {
  GeneratedFunction(
    [arg1 |> to_dynamic, arg2 |> to_dynamic],
    returns |> to_dynamic,
  )
}

pub fn function3(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  arg3: GeneratedType(arg3),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1, arg2, arg3) -> ret) {
  GeneratedFunction(
    [arg1 |> to_dynamic, arg2 |> to_dynamic, arg3 |> to_dynamic],
    returns |> to_dynamic,
  )
}

pub fn function4(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  arg3: GeneratedType(arg3),
  arg4: GeneratedType(arg4),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1, arg2, arg3, arg4) -> ret) {
  GeneratedFunction(
    [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
    ],
    returns |> to_dynamic,
  )
}

pub fn function5(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  arg3: GeneratedType(arg3),
  arg4: GeneratedType(arg4),
  arg5: GeneratedType(arg5),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1, arg2, arg3, arg4, arg5) -> ret) {
  GeneratedFunction(
    [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
    ],
    returns |> to_dynamic,
  )
}

pub fn function6(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  arg3: GeneratedType(arg3),
  arg4: GeneratedType(arg4),
  arg5: GeneratedType(arg5),
  arg6: GeneratedType(arg6),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1, arg2, arg3, arg4, arg5, arg6) -> ret) {
  GeneratedFunction(
    [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
      arg6 |> to_dynamic,
    ],
    returns |> to_dynamic,
  )
}

pub fn function7(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  arg3: GeneratedType(arg3),
  arg4: GeneratedType(arg4),
  arg5: GeneratedType(arg5),
  arg6: GeneratedType(arg6),
  arg7: GeneratedType(arg7),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7) -> ret) {
  GeneratedFunction(
    [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
      arg6 |> to_dynamic,
      arg7 |> to_dynamic,
    ],
    returns |> to_dynamic,
  )
}

pub fn function8(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  arg3: GeneratedType(arg3),
  arg4: GeneratedType(arg4),
  arg5: GeneratedType(arg5),
  arg6: GeneratedType(arg6),
  arg7: GeneratedType(arg7),
  arg8: GeneratedType(arg8),
  returns: GeneratedType(ret),
) -> GeneratedType(fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8) -> ret) {
  GeneratedFunction(
    [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
      arg6 |> to_dynamic,
      arg7 |> to_dynamic,
      arg8 |> to_dynamic,
    ],
    returns |> to_dynamic,
  )
}

pub fn function9(
  arg1: GeneratedType(arg1),
  arg2: GeneratedType(arg2),
  arg3: GeneratedType(arg3),
  arg4: GeneratedType(arg4),
  arg5: GeneratedType(arg5),
  arg6: GeneratedType(arg6),
  arg7: GeneratedType(arg7),
  arg8: GeneratedType(arg8),
  arg9: GeneratedType(arg9),
  returns: GeneratedType(ret),
) -> GeneratedType(
  fn(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9) -> ret,
) {
  GeneratedFunction(
    [
      arg1 |> to_dynamic,
      arg2 |> to_dynamic,
      arg3 |> to_dynamic,
      arg4 |> to_dynamic,
      arg5 |> to_dynamic,
      arg6 |> to_dynamic,
      arg7 |> to_dynamic,
      arg8 |> to_dynamic,
      arg9 |> to_dynamic,
    ],
    returns |> to_dynamic,
  )
}

pub fn get_return_type(function: GeneratedType(any)) {
  case function {
    GeneratedFunction(_, ret) -> ret
    _ -> Dynamic
  }
}

@internal
pub fn custom_type(
  module: option.Option(String),
  name: String,
  types: List(GeneratedType(Dynamic)),
) -> GeneratedType(a) {
  CustomType(module, name, types)
}

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn to_dynamic(type_: GeneratedType(t)) -> GeneratedType(Dynamic)

@external(erlang, "gleamgen_ffi", "identity")
@external(javascript, "../gleamgen_ffi.mjs", "identity")
pub fn coerce_dynamic_unsafe(type_: GeneratedType(Dynamic)) -> GeneratedType(a)

pub fn render_type(type_: GeneratedType(a)) -> Result(render.Rendered, Nil) {
  case type_ {
    GeneratedBool ->
      doc.from_string("Bool")
      |> render.Render(details: render.empty_details)
      |> Ok
    GeneratedString ->
      doc.from_string("String")
      |> render.Render(details: render.empty_details)
      |> Ok
    GeneratedInt ->
      doc.from_string("Int")
      |> render.Render(details: render.empty_details)
      |> Ok
    GeneratedFloat ->
      doc.from_string("Float")
      |> render.Render(details: render.empty_details)
      |> Ok
    GeneratedNil ->
      doc.from_string("Nil")
      |> render.Render(details: render.empty_details)
      |> Ok
    GeneratedList(t) -> render_custom(option.None, "List", [t])
    GeneratedTuple(t) -> render_tuple(t)
    CustomType(module, name, types) -> render_custom(module, name, types)
    Dynamic -> Error(Nil)
    Raw(t) -> {
      let used_imports = case string.split_once(t, ".") {
        Ok(#(module, _)) -> [module]
        Error(Nil) -> []
      }
      doc.from_string(t)
      |> render.Render(details: render.RenderedDetails(used_imports:))
      |> Ok
    }
    Generic(t) ->
      doc.from_string(t) |> render.Render(details: render.empty_details) |> Ok
    GeneratedFunction(args, return) -> {
      render_function(args, return)
    }
  }
}

fn render_type_list(types: List(GeneratedType(Dynamic))) {
  let possibly_rendered =
    types
    |> list.try_fold(#([], render.empty_details), fn(acc, t) {
      render_type(t)
      |> result.map(fn(rendered) {
        #(
          [rendered.doc, ..acc.0],
          render.merge_details(rendered.details, acc.1),
        )
      })
    })
  possibly_rendered |> result.map(fn(r) { #(r.0 |> list.reverse(), r.1) })
}

fn render_custom(
  module: option.Option(String),
  name: String,
  types: List(GeneratedType(Dynamic)),
) -> Result(render.Rendered, Nil) {
  let rendered = render_type_list(types)
  use #(rendered_types, details) <- result.try(rendered)

  let #(used_imports, import_details) = case module {
    option.Some(m) -> #([m, ..details.used_imports], doc.from_string(m <> "."))
    option.None -> #(details.used_imports, doc.empty)
  }

  import_details
  |> doc.append(doc.from_string(name))
  |> doc.append(case types {
    [] -> doc.empty
    _ -> render.pretty_list(rendered_types)
  })
  |> render.Render(details: render.RenderedDetails(used_imports:))
  |> Ok
}

fn render_tuple(
  types: List(GeneratedType(Dynamic)),
) -> Result(render.Rendered, Nil) {
  let rendered = render_type_list(types)
  use #(rendered_types, details) <- result.try(rendered)
  doc.from_string("#")
  |> doc.append(render.pretty_list(rendered_types))
  |> render.Render(details:)
  |> Ok
}

fn render_function(args, return) {
  let rendered = render_type_list(args)
  use #(rendered_types, details) <- result.try(rendered)
  let return = render_type(return)

  let used_imports = case return {
    Ok(ret) -> list.append(ret.details.used_imports, details.used_imports)
    Error(Nil) -> details.used_imports
  }

  doc.concat([
    doc.from_string("fn"),
    render.pretty_list(rendered_types),
    doc.space,
    case return {
      Ok(ret) -> doc.concat([doc.from_string("->"), doc.space, ret.doc])
      Error(_) -> doc.empty
    },
  ])
  |> render.Render(details: render.RenderedDetails(used_imports:))
  |> Ok
}
