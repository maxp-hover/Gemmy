module Gemmy::Patches::IntegerPatch

  module ClassMethods

    module RomanValues
      # facets
      def roman_values
        [
          ["M", 1000],
          ["CM", 900],
          ["D",  500],
          ["CD", 400],
          ["C",  100],
          ["XC",  90],
          ["L",   50],
          ["XL",  40],
          ["X",   10],
          ["IX",   9],
          ["V",    5],
          ["IV",   4],
          ["I",    1]
        ].to_h
      end
    end

  end

  module InstanceMethods

    module Hundred
      # from powerpack
      def hundred
        self * Gemmy.const("HUNDRED")
      end
    end
    module Thousand
      # from powerpack
      def thousand
        self * Gemmy.const("THOUSAND")
      end
    end
    module Million
      # from powerpack
      def million
        self * Gemmy.const("MILLION")
      end
    end
    module Billion
      # from powerpack
      def billion
        self * Gemmy.const("BILLION")
      end
    end
    module Trillion
      # from powerpack
      def trillion
        self * Gemmy.const("TRILLION")
      end
    end
    module Quadrillion
      # from powerpack
      def quadrillion
        self * Gemmy.const("QUADRILLION")
      end
    end

    module Factorial
      # facets
      def factorial
        return 1 if zero?
        f = 1
        2.upto(self) { |n| f *= n }
        f
      end
    end

    module MultipleOf
      # facets
      def multiple_of?(number)
        if number.zero?
          zero? ? true : false
        else
          self % number == 0
        end
      end
    end

    module Odd
      def odd?
        ! even?
      end
    end

    module Of
      # facets
      def of(&block)
        Array.new(self, &block)
      end
      alias times_map of
    end

    module Collapse
      # facets
      def collapse
        flatten.compact
      end
    end

  end

end
