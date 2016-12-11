# Hash patches
#
module Gemmy::Patches::HashPatch

  module ClassMethods
  end

  module InstanceMethods

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
        Gemmy::Patches::HashPatch::InstanceMethods::Bury._bury(self, *args)
      end
      # The bury method, taking the input hash as a parameter
      # Used by the Hash#bury instance method
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
        autovivified = Gemmy::Patches::HashPatch::InstanceMethods::Autovivified.method(:_autovivified)
        autovivified.call(self).tap do |hash|
          hash.instance_exec do
            @db = YAML::Store.new path
            @db.transaction do
              @db[:data] = autovivified.call({})
            end
          end
          hash.extend Gemmy::Patches::HashPatch::PersistedHash
        end
      end
    end

  end # end instance methods

  # Helper methods for the persistence patch
  #
  module PersistedHash
    def get(*keys, disk: false)
      disk ? @db.transaction { @db[:data].dig(*keys) } : dig(*keys)
    end
    def set(*keys, val)
      bury = Gemmy::Patches::HashPatch::InstanceMethods::Bury.method(:_bury)
      bury.call(self, *keys, val)
      @db.transaction do
        bury.call(@db[:data], *(keys + [val]))
      end
      val
    end
  end

end
