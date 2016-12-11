module Gemmy::Patches::IntegerPatch

  module ClassMethods

  end

  module InstanceMethods

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
