import gleamgen/expression
import gleamgen/types
import gleamgen/types/variant

pub type Construtor(construct_to, args) {
  Construtor(variant: variant.Variant(types.Unchecked))
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
