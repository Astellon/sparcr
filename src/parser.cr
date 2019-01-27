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
end
