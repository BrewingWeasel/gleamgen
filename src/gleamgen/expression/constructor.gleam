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

pub fn to_expression_unchecked(
  constructor: Construtor(construct_to, _),
) -> expression.Expression(construct_to) {
  expression.unchecked_ident(constructor.variant.name)
}
