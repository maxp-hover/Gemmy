module Gemmy::Patches::EnumeratorPatch
  module ClassMethods
  end
  module InstanceMethods
    module MapBy
      using CF::Enumerable::MapBy
      # maps to hash
      # Each iteration returns array [hash_key, hash_val]
      # hash values are stored in arrays
      def map_by(&blk)
        clone.map_by &blk
      end
    end

    module MapTo
      using CF::Enumerable::MapTo
      # map to <klass> instances, passing self as arg to klass constructor
      def map_to(klass)
        clone.map_to klass
      end
    end
  end
end
