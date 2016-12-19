# Hash patches
#
module Gemmy::Patches::HashPatch

  module ClassMethods
    # facets
    # Hash.zip(["a","b","c"], [1,2,3])
    # => { "a"=>1, "b"=>2, "c"=>3 }
    module Zip
      def zip(keys,values) # or some better name
        h = {}
        keys.size.times{ |i| h[ keys[i] ] = values[i] }
        h
      end
    end
  end

  module InstanceMethods

    module UpdateKeys
      # facets
      # in place
      def update_keys #:yield:
        if block_given?
          keys.each { |old_key| store(yield(old_key), delete(old_key)) }
        else
          to_enum(:update_keys)
        end
      end
    end

    module UpdateValues
      # facets
      # in place
      def update_values #:yield:
        if block_given?
          each{ |k,v| store(k, yield(v)) }
        else
          to_enum(:update_values)
        end
      end
    end

    module ToOpenStruct
      # facets
      def to_ostruct
        OpenStruct.new(self)
      end
      def recursive_to_ostruct(exclude={})
        return exclude[self] if exclude.key?( self )
        o = exclude[self] = OpenStruct.new
        h = self.dup
        each_pair do |k,v|
          h[k] = v.to_ostruct_recurse( exclude ) if v.respond_to?(:to_ostruct_recurse)
        end
        o.merge!(h)
      end
    end

    module Rekey
      # facets
      # rekey according to a block, i.e. {a: 1}.rekey &:to_s
      def rekey(key_map=nil, &block)
        raise ArgumentError, "argument or block" if key_map && block

        if !(key_map or block)
          block = lambda{|k| k.to_sym}
        end

        if block
          hash = dup.clear
          if block.arity.abs == 1
            each_pair do |k, v|
              hash[block[k]] = v     #hash[block[k] || k] = v
            end
          else
            each_pair do |k, v|
              hash[block[k,v]] = v   #hash[block[k,v] || k] = v
            end
          end
        else
          #hash = dup.clear  # to keep default_proc
          #(keys - key_map.keys).each do |key|
          #  hash[key] = self[key]
          #end
          #key_map.each do |from, to|
          #  hash[to] = self[from] if key?(from)
          #end
          hash = dup  # to keep default_proc
          key_map.each_pair do |from, to|
            hash[to] = hash.delete(from) if hash.key?(from)
          end
        end

        hash
      end
    end

    module Recurse
      # facets
      # h = {:a=>1, :b=>{:b1=>1, :b2=>2}}
      # g = h.recurse{|h| h.inject({}){|h,(k,v)| h[k.to_s] = v; h} }
      # g  #=> {"a"=>1, "b"=>{"b1"=>1, "b2"=>2}}
      def recurse(*types, &block)
        types = [self.class] if types.empty?
        h = inject({}) do |hash, (key, value)|
          case value
          when *types
            hash[key] = value.recurse(*types, &block)
          else
            hash[key] = value
          end
          hash
        end
        yield h
      end
    end

    module HasKeys
      # facets
      # checks if a list of keys are all present
      def keys?(*check_keys)
        unknown_keys = check_keys - self.keys
        return unknown_keys.empty?
      end
    end

    module OnlyKeys
      # facets
      # checks if these are the only keys
      def only_keys?(*check_keys)
        unknown_keys = self.keys - check_keys
        return unknown_keys.empty?
      end
    end

    module Join
      # facets
      # returns a string
      def join(pair_divider='', elem_divider=nil)
        elem_divider ||= pair_divider
        s = []
        each{ |k,v| s << "#{k}#{pair_divider}#{v}" }
        s.join(elem_divider)
      end
    end

    module Inverse
      # facets
      # h = {"a"=>3, "b"=>3, "c"=>3, "d"=>2, "e"=>9, "f"=>3, "g"=>9}
      # h.invert           #=> {2=>"d", 3=>"f", 9=>"g"}
      # h.inverse          #=> {2=>"d", 3=>["f", "c", "b", "a"], 9=>["g", "e"]}
      # h.inverse.inverse  #=> {"a"=>3, "b"=>3, "c"=>3, "d"=>2, "e"=>9, "f"=>3, "g"=>9}
      def inverse
        i = Hash.new
        self.each_pair{ |k,v|
          if (Array === v)
            v.each{ |x| i[x] = ( i.has_key?(x) ? [k,i[x]].flatten : k ) }
          else
            i[v] = ( i.has_key?(v) ? [k,i[v]].flatten : k )
          end
        }
        return i
      end
    end

    module Diff
      # facets
      # returns the key-vals from <self> that are not the same in <hash>
      def diff(hash)
        h1 = self.dup.delete_if{ |k,v| hash[k] == v }
        h2 = hash.dup.delete_if{ |k,v| has_key?(k) }
        h1.merge(h2)
      end
    end

    module Except
      # facets
      # excludes vertain keys
      def except(*less_keys)
        hash = dup
        less_keys.each{ |k| hash.delete(k) }
        hash
      end
    end

    module DeleteUnless
      # facets
      def delete_unless #:yield:
        delete_if{ |key, value| ! yield(key, value) }
      end
    end

    # The opposite of Hash#dig
    # Takes a list of keys followed by a value to set
    #
    # Example:
    #
    #   a = {a: {b: {}} }
    #   a.bury(:a, :b, :c, 0)
    #   puts a[:a][:b][:c]
    #   => 0
    #
    # Source: https://github.com/dam13n/ruby-bury/blob/master/hash.rb
    #
    module Bury
      def bury *args
        Gemmy.patch("hash/i/bury")._bury self, *args
      end
      # The bury method, taking the input hash as a parameter
      def self._bury(caller_hash, *args)
        if args.count < 2
          raise ArgumentError.new("2 or more arguments required")
        elsif args.count == 2
          caller_hash[args[0]] = args[1]
        else
          arg = args.shift
          caller_hash[arg] = {} unless caller_hash[arg]
          _bury(caller_hash[arg], *args) unless args.empty?
        end
        caller_hash
      end
    end

    # Turns a hash into one that's "autovivified"
    # meaning it's default values for keys is an empty hash.
    # The result is that you can set nested keys without initializing
    # more than one hash layer.
    #
    # Usage:
    #   hash = {}.autovivified
    #   hash[:a][:b] = 0
    #   puts hash[:a][:b]
    #   => 0
    #
    module Autovivified
      def self._autovivified(caller_hash)
        result = Hash.new do |hash,key|
          hash[key] = Hash.new(&hash.default_proc)
        end
        result.deep_merge caller_hash
      end
      def autovivified
        Gemmy::Patches::HashPatch::InstanceMethods::Autovivified._autovivified(self)
      end
    end

    # Sets up a hash to mirror all changes to a database file
    # All nested gets & sets require a list of keys, passed as subsequent args.
    # Instead of [] and []=, use get and set
    #
    # Everything in the db is contained in a hash with one predefined
    # key, :data. The value is an empty, autovivified hash.
    #
    # This also makes the caller hash autovivified
    #
    # Example:
    #
    # hash = {}.persisted("db.yaml")
    # hash.set(:a, :b, 0)           # => this writes to disk and memory
    # hash.get(:a, :b)              # => reads from memory
    # hash.get(:a, :b, disk: true)  # => reads from disk
    #

    module Persisted
      def persisted(path)
        require 'yaml/store'
        autovivified = Gemmy.patch("hash/i/autovivified")\
                            .method(:_autovivified)
        autovivified.call(self).tap do |hash|
          hash.instance_exec do
            @store = YAML::Store.new path
            @store.transaction do
              @store[:data] ||= autovivified.call({})
              @store[:data].each { |k,v| self[k] = v.deep_dup }
            end
          end
          hash.extend Gemmy::Patches::HashPatch::PersistedHash
        end
      end
      def db
        @store
      end
    end

  end # end instance methods

  # Helper methods for the persistence patch
  #
  module PersistedHash
    def get(*keys, disk: true)
      disk ? @store.transaction { @store[:data].dig(*keys) } : dig(*keys)
    end
    def set(*keys, val)
      bury = Gemmy::Patches::HashPatch::InstanceMethods::Bury.method(:_bury)
      bury.call(self, *keys, val)
      @store.transaction do
        bury.call(@store[:data], *(keys + [val]))
      end
      val
    end
    def data
      @store.transaction { @store[:data] }
    end
    def clear
      autovivified = Gemmy.patch("hash/i/autovivified")\
                          .method(:_autovivified)
      @store.transaction { @store[:data] = autovivified.call({}) }
    end
  end

end
