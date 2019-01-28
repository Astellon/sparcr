require "../src/sparcr"

include Sparcr

isdigit = Satisfy(Int32).new(->(x : Char) { !x.to_i?.nil? })
integer = Many.new(isdigit).reduce { |x, y| x * 10 + y }
add_op = Literal.new("+") | Literal.new("-")
mul_op = Literal.new("*") | Literal.new("/")

mul_expr = integer + Many.new(mul_op + integer)
add_expr = (mul_expr + Many.new(add_op + mul_expr))
expr = add_expr

puts expr.parse("123+456+789").value
