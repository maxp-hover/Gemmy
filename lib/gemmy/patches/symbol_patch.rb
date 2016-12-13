# Symbol patches
#
module Gemmy::Patches::SymbolPatch

  module ClassMethods
  end

  module InstanceMethods

    module Call
      using CF::Symbol[:call]
      def call(*args, &blk)
        Gemmy.patch("symbol/i/call")._call self, *args, &blk
      end
      def self._call(sym, *args, &blk)
        sym.call *args, &blk
      end
    end

    module Variablize
      # facets
      # take a symbol and make it fine for an instance variable name
      def variablize
        name = to_s.gsub(/\W/, '_')
        "@#{name}".to_sym
      end
    end

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
