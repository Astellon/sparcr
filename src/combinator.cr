module Sparcr
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

  class Many(T) < Parser(Array(T) | T)
    def initialize(@p : Parser(T))
    end

    def parse(input : String)
      values = Array(T).new
      left = input
      while true
        result = @p.parse(left)

        if result.is_a?(Fail)
          puts @reduce_block.nil?

          # for type interface skipping nil
          callback = @reduce_block
          if callback.nil?
            return Success(Array(T)).new(values, left)
          else
            # should reconstruct block
            return Success(T).new(values.reduce { |x, y| callback.call(x, y) }, left)
          end
        end
        
        values << result.value
        left = result.left
      end
    end

    def reduce(&block : (T, T)->T)
      @reduce_block = block
      self # return self for chainning
    end
  end
end