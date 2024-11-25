import gleamgen/expression
import gleamgen/types
import gleamgen/types/custom
import gleamgen/types/variant

/// Use to_expression[n] or to_expression_unchecked to create an expression from the constructor.
pub opaque type Constructor(construct_to, args, generics) {
  Constructor(variant: variant.Variant(types.Unchecked))
}

pub type Variants1(a) =
  #(#(), a)

pub type Variants2(a, b) =
  #(#(#(), a), b)

pub type Variants3(a, b, c) =
  #(#(#(#(), a), b), c)

pub type Variants4(a, b, c, d) =
  #(#(#(#(#(), a), b), c), d)

pub type Variants5(a, b, c, d, e) =
  #(#(#(#(#(#(), a), b), c), d), e)

pub type Variants6(a, b, c, d, e, f) =
  #(#(#(#(#(#(#(), a), b), c), d), e), f)

pub type Variants7(a, b, c, d, e, f, g) =
  #(#(#(#(#(#(#(#(), a), b), c), d), e), f), g)

pub type Variants8(a, b, c, d, e, f, g, h) =
  #(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h)

pub type Variants9(a, b, c, d, e, f, g, h, i) =
  #(#(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h), i)

@internal
pub fn new(
  variant: variant.Variant(types.Unchecked),
) -> Constructor(construct_to, a, generics) {
  Constructor(variant)
}

pub fn to_expression0(
  constructor: Constructor(construct_to, #(), generics),
) -> expression.Expression(construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression1(
  constructor: Constructor(construct_to, Variants1(a), generics),
) -> expression.Expression(fn(a) -> custom.CustomType(construct_to, generics)) {
  expression.unchecked_ident(constructor.variant.name)
}

// rest of repetitive expression generators
// {{{

pub fn to_expression2(
  constructor: Constructor(construct_to, Variants2(a, b), generics),
) -> expression.Expression(
  fn(a, b) -> custom.CustomType(construct_to, generics),
) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression3(
  constructor: Constructor(construct_to, Variants3(a, b, c), generics),
) -> expression.Expression(
  fn(a, b, c) -> custom.CustomType(construct_to, generics),
) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression4(
  constructor: Constructor(construct_to, Variants4(a, b, c, d), generics),
) -> expression.Expression(fn(a, b, c, d) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression5(
  constructor: Constructor(construct_to, Variants5(a, b, c, d, e), generics),
) -> expression.Expression(fn(a, b, c, d, e) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression6(
  constructor: Constructor(construct_to, Variants6(a, b, c, d, e, f), generics),
) -> expression.Expression(fn(a, b, c, d, e, f) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression7(
  constructor: Constructor(
    construct_to,
    Variants7(a, b, c, d, e, f, g),
    generics,
  ),
) -> expression.Expression(fn(a, b, c, d, e, f, g) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression8(
  constructor: Constructor(
    construct_to,
    Variants8(a, b, c, d, e, f, g, h),
    generics,
  ),
) -> expression.Expression(fn(a, b, c, d, e, f, g, h) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression9(
  constructor: Constructor(
    construct_to,
    Variants9(a, b, c, d, e, f, g, h, i),
    generics,
  ),
) -> expression.Expression(fn(a, b, c, d, e, f, g, h, i) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

// }}}

pub fn to_expression_unchecked(
  constructor: Constructor(construct_to, _, _),
) -> expression.Expression(a) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn name(constructor: Constructor(_, _, _)) -> String {
  constructor.variant.name
}

pub fn unsafe_convert(
  constructor: Constructor(construct_to, original_variants, original_generics),
) -> Constructor(construct_to, new_variants, new_generics) {
  Constructor(variant: constructor.variant)
}
// vim: foldmethod=marker foldlevel=0
