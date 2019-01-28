require "./spec_helper"

describe Sparcr do
  it "Satisfy" do
    Satisfy(Int32).new(->(x : Char) { x == '1' }).parse("123").value.should eq 1
  end

  it "Literal" do
    Literal.new("Crystal").parse("Crystal Lang").value.should eq "Crystal"
  end

  it "Cat" do
    (Literal.new("Crystal") + Literal.new(" ") + Literal.new("Lang")).parse("Crystal Lang").value
  end

  it "Or" do
    (Literal.new("Ruby") | Literal.new("Crystal")).parse("Crystal Lang").value
  end

  it "many" do
    Sparcr.many(Literal.new("Crystal ")).parse("Crystal Crystal Crystal").value
  end

  it "parse integer" do
    Sparcr.many(Satisfy(Int32).new(->(x : Char) { !x.to_i?.nil? })).parse("123").value.reduce { |x, y| x*10 + y }.should eq 123
  end
end
