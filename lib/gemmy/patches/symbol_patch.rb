# Symbol patches
#
module Gemmy::Patches::SymbolPatch

  module ClassMethods
  end

  module InstanceMethods

    # Patch symbol so the proc shorthand can take extra arguments
    # http://stackoverflow.com/a/23711606/2981429
    #
    # Example: [1,2,3].map &:*.with(2)
    # => [2,4,6]
    #
    module With
      def with(*args, &block)
        ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
      end
    end

  end


end
