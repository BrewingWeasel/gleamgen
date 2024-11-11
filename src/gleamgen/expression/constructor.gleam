import gleamgen/expression
import gleamgen/types
import gleamgen/types/variant

/// Use to_expression[n] or to_expression_unchecked to create an expression from the constructor.
pub opaque type Construtor(construct_to, args) {
  Construtor(variant: variant.Variant(types.Unchecked))
}

@internal
pub fn new(
  variant: variant.Variant(types.Unchecked),
) -> Construtor(construct_to, a) {
  Construtor(variant)
}

pub fn to_expression0(
  constructor: Construtor(construct_to, #()),
) -> expression.Expression(construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression1(
  constructor: Construtor(construct_to, #(#(), a)),
) -> expression.Expression(fn(a) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

// rest of repetitive expression generators
// {{{

pub fn to_expression2(
  constructor: Construtor(construct_to, #(#(#(), a), b)),
) -> expression.Expression(fn(a, b) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression3(
  constructor: Construtor(construct_to, #(#(#(#(), a), b), c)),
) -> expression.Expression(fn(a, b, c) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression4(
  constructor: Construtor(construct_to, #(#(#(#(#(), a), b), c), d)),
) -> expression.Expression(fn(a, b, c, d) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression5(
  constructor: Construtor(construct_to, #(#(#(#(#(#(), a), b), c), d), e)),
) -> expression.Expression(fn(a, b, c, d, e) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression6(
  constructor: Construtor(construct_to, #(#(#(#(#(#(#(), a), b), c), d), e), f)),
) -> expression.Expression(fn(a, b, c, d, e, f) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression7(
  constructor: Construtor(
    construct_to,
    #(#(#(#(#(#(#(#(), a), b), c), d), e), f), g),
  ),
) -> expression.Expression(fn(a, b, c, d, e, f, g) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression8(
  constructor: Construtor(
    construct_to,
    #(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h),
  ),
) -> expression.Expression(fn(a, b, c, d, e, f, g, h) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn to_expression9(
  constructor: Construtor(
    construct_to,
    #(#(#(#(#(#(#(#(#(#(), a), b), c), d), e), f), g), h), i),
  ),
) -> expression.Expression(fn(a, b, c, d, e, f, g, h, i) -> construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}

// }}}

pub fn to_expression_unchecked(
  constructor: Construtor(construct_to, _),
) -> expression.Expression(a) {
  expression.unchecked_ident(constructor.variant.name)
}

pub fn name(constructor: Construtor(_, _)) -> String {
  constructor.variant.name
}
// vim: foldmethod=marker foldlevel=0
