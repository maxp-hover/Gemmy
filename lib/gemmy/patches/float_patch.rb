module Gemmy::Patches::FloatPatch
  module ClassMethods
  end
  module InstanceMethods

    module RoundTo
      # facets
      # i.e. 2.046.round_to(0.01) == 2.05
      def round_to( n ) #n=1
        return self if n == 0
        (self * (1.0 / n)).round.to_f / (1.0 / n)
      end
    end

  end
end
