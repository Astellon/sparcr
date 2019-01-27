require "./result.cr"

module Sparcr
  abstract class Parser(T)
    abstract def parse(input : String)

    def +(other : Parser(U)) forall U
      return Cat(T, U).new(self, other)
    end

    def |(other : Parser(U)) forall U
      return Or(T, U).new(self, other)
    end
  end

  def self.many(p : Parser(T)) forall T
    return Many(T).new(p)
  end

  class Satisfy(T) < Parser(T)
    def initialize(@pred : Proc(Char, Bool))
    end

    def parse(input : String)
      if input.size < 1 || !@pred.call(input[0])
        return Fail.new("not satisfy", input)
      else
        return Success(T).new(T.new("" + input[0]), input[1..input.size])
      end
    end
  end

  class Literal < Parser(String)
    def initialize(@pattern : String)
    end

    def parse(input : String)
      if input.size < 1 || !input.starts_with?(@pattern)
        return Fail.new("not starts with " + input, input)
      else
        return Success(String).new(@pattern, input.lchop(@pattern))
      end
    end
  end

  class Cat(T, U) < Parser(Tuple(T, U))
    def initialize(@p1 : Parser(T), @p2 : Parser(U))
    end

    def parse(input : String)
      lresult = @p1.parse(input)
      return lresult if lresult.is_a?(Fail)
      rresult = @p2.parse(lresult.left)
      return Fail.new(rresult.message, input) if rresult.is_a?(Fail)
      return Success(Tuple(T, U)).new({lresult.value, rresult.value}, rresult.left)
    end
  end

  class Or(T, U) < Parser(T | U)
    def initialize(@p1 : Parser(T), @p2 : Parser(U))
    end

    def parse(input : String)
      lresult = @p1.parse(input)
      return lresult if lresult.is_a?(Success)
      rresult = @p2.parse(input)
      return rresult if rresult.is_a?(Success)
      return Fail.new(lresult.message + " and " + rresult.message, input)
    end
  end

  class Many(T) < Parser(Array(T))
    def initialize(@p : Parser(T))
    end

    def parse(input : String)
      values = Array(T).new
      left = input
      while true
        result = @p.parse(left)
        return Success(Array(T)).new(values, left) if result.is_a?(Fail)
        values << result.value
        left = result.left
      end
    end
  end

  puts Satisfy(Int32).new(->(x : Char) { x == '1' }).parse("123").value
  puts (Literal.new("Crystal") + Literal.new(" ") + Literal.new("Lang")).parse("Crystal Lang").value
  puts (Literal.new("Ruby") | Literal.new("Crystal")).parse("Crystal Lang").value
  puts many(Literal.new("Crystal ")).parse("Crystal Crystal Crystal").value
  puts many(Satisfy(Int32).new(->(x : Char) { !x.to_i?.nil? })).parse("123").value.reduce { |x, y| x*10 + y }
end
