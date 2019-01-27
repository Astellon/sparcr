module Sparcr
  abstract class Result(T)
    getter value : T
    getter left : String

    def initialize(@value, @left)
    end
  end

  class Success(T) < Result(T)
  end

  class Fail < Result(Nil)
    getter message : String

    def initialize(@message, @left)
    end
  end
end
