module Gemmy::Patches::EnumeratorPatch
  module ClassMethods
  end
  module InstanceMethods

    # Facets
    # Similar to map by (array => hash)
    # but values are not wrapped in arrays
    # iteration return val is [key, val]
    module Graph
      def graph(&yld)
        if yld
          h = {}
          each do |*kv|
            r = yld[*kv]
            case r
            when Hash
              nk, nv = *r.to_a[0]
            when Range
              nk, nv = r.first, r.last
            else
              nk, nv = *r
            end
            h[nk] = nv
          end
          h
        else
          Enumerator.new(self,:graph)
        end
      end
    end

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

    module Frequencies
      # taken from powerpack
      # maps each element in the enum to it's num occurrances
      def frequencies
        each_with_object(Hash.new(0)) { |e, a| a[e] += 1 }
      end
    end



  end
end
