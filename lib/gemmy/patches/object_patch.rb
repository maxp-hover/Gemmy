# Object patches. Can be called with implicit receiver
#
# Patches which are originally specified as being for Kernel (by facets,
# for examples), are implemented here as patches on Object because Kernel is
# a module and Ruby doesn't support refinements on Modules. Object includes
# and extends Kernel so it's the same effect.
#
module Gemmy::Patches::ObjectPatch

  # This class is redundant here, since Object's instance methods
  # are available at the class scope anyway.
  module ClassMethods
  end

  module InstanceMethods

    module Home
      # the $HOME dir, aka ~
      def home
        `echo $HOME`.chomp
      end
    end

    module ObjectState
      # class StateExample
      #   attr_reader :a, :b
      #   def initialize(a,b)
      #     @a, @b = a, b
      #   end
      # end

      # obj = StateExample.new(1,2)
      # obj.a  #=> 1
      # obj.b  #=> 2

      # obj.object_state  #=> {:a=>1, :b=>2}

      # obj.object_state(:a=>3, :b=>4)
      # obj.a  #=> 3
      # obj.b  #=> 4
      def object_state(data=nil)
        if data
          instance_variables.each do |iv|
            name = iv.to_s.sub(/^[@]/, '').to_sym
            instance_variable_set(iv, data[name])
          end
        else
          data = {}
          instance_variables.each do |iv|
            name = iv.to_s.sub(/^[@]/, '').to_sym
            data[name] = instance_variable_get(iv)
          end
          data
        end
      end
    end

    module Itself
      # facets
      def itself
        def itself
          self
        end
      end
    end

    module Try
      # facets
      # nicer than the builtin
      # @example.try.name    #=> "bob"
      # @people.try(:collect){ |p| p.name }
      def try(method=nil, *args, &block)
        if method
          __send__(method, *args, &block)
        else
          self
        end
      end
    end

    module Not
      # facets
      # true.nil?.not? == !true.nil?
      def not?
        !self
      end
    end

    module Truthy
      def truthy
        !! self
      end
    end

    module Falsy
      def Falsy
        ! self
      end
    end

    module NotNil
      # facets
      def not_nil?
        ! nil?
      end
    end

    module Maybe
      # Random generator that returns true or false. Can also take a block that has a 50/50 chance to being executed…
      # facets
      def maybe(chance = 0.5, &block)
        if block
          yield if rand < chance
        else
          rand < chance
        end
      end
    end

    module InstanceAssign
      # facets
      # assign instance variables with a hash
      def instance_assign(hash)
        hash.each do |k,v|
          k = "@#{k}" if k !~ /^@/
          instance_variable_set(k, v)
        end
        self
      end
    end

    module HierarchicalSend
      # facets
      # Send a message to each ancestor in an object's class hierarchy. The method will only be called if the method is defined for the ancestor.
      # This can be very useful for setting up a `preinitialize` system.
      #
      # Example:
      # m = Module.new do
      #       attr :a
      #       def preinitialize
      #         @a = 1
      #       end
      #     end
      #
      # c = Class.new do
      #       include m
      #       def initialize
      #         hierarchical_send(:preinitialize)
      #       end
      #     end

      # c.new.a  #=> 1
      def hierarchical_send(method_name, *args, &block)
        method_name = method_name.to_s if RUBY_VERSION < '1.9'
        this = self
        self.class.hierarchically do |anc|
          ## is there really no better way to check for the method?
          if anc.instance_methods(false).include?(method_name) or
               anc.public_instance_methods(false).include?(method_name) or
               anc.private_instance_methods(false).include?(method_name) or
               anc.protected_instance_methods(false).include?(method_name)
            im = anc.instance_method(method_name)
            ##im.arity == 0 ? im.bind(this).call(&block) : im.bind(this).call(*args, &block)
            im.bind(this).call(*args, &block)
          end
        end
      end
    end

    module Ergo
      # facets
      # This is like #tap, but #tap yields self and returns self,
      # where as #ergo yields self but returns the result.
      def ergo(&b)
        if block_given?
          b.arity > 0 ? yield(self) : instance_eval(&b)
        else
          self
        end
      end
    end

    module DeepCopy
      # facets
      def deep_copy
        Marshal::load(Marshal::dump(self))
      end
    end

    module Constant
      # facets
      # like Module#const_get accessible at all levels
      # and handles module hierarchy.
      # constant("Process::Sys")
      def constant(const)
        const = const.to_s.dup
        base = const.sub!(/^::/, '') ? Object : ( self.kind_of?(Module) ? self : self.class )
        const.split(/::/).inject(base){ |mod, name| mod.const_get(name) }
      end
    end

    module Bool
      # facets
      def bool?
        (true == self or false == self)
      end
    end

    module AttrSingletonAccessor
      # facets
      # obj = Object.new
      # obj.attr_singleton_accessor :x, :y
      def attr_singleton_accessor(*args)
        #h, a = *args.partition{|a| Hash===a}
        (class << self ; self ; end).send( :attr_accessor, *args )
        #(class << self ; self ; end).send( :attr_accessor, *h.keys )
        #h.each { |k,v| instance_variable_set("@#{k}", v) }
      end
    end

    module AttrSingletonReader
      # facets
      def attr_singleton_reader(*args)
        #h, a = *args.partition{|a| Hash===a}
        (class << self ; self ; end).send( :attr_reader, *args )
        #(class << self ; self ; end).send( :attr_reader, *h.keys )
        #h.each { |k,v| instance_variable_set("@#{k}", v) }
      end
    end

    module AttrSingletonWriter
      # facets
      def attr_singleton_writer(*args)
        #h, a = *args.partition{|a| Hash===a}
        (class << self ; self ; end).send( :attr_writer, *args )
        #(class << self ; self ; end).send( :attr_writer, *h.keys )
        #h.each { |k,v| instance_variable_set("@#{k}", v) }
      end
    end


    # Turns on verbose mode, showing warnings
    #
    module VerboseMode
      def verbose_mode
        $VERBOSE = true
      end
    end

    # Generic error. Raises RuntimeError
    # @param msg [String] optional
    #
    module Error
      def error(msg='')
        raise RuntimeError, msg
      end
    end

    module Ask
      # facets
      def ask(prompt=nil)
        $stdout << "#{prompt}"
        $stdout.flush
        $stdin.gets.chomp!
      end
    end

    # Prints a string then gets input
    # @param txt [String]
    #
    module Prompt
      def _prompt(txt)
        puts txt
        gets.chomp
      end
    end

    # Shifts one ARGV and raises a message if it's undefined.
    # @param msg [String]
    #
    module GetArgOrError
      def get_arg_or_error(msg)
        ([ARGV.shift, msg].tap &method(:error_if_blank)).shift
      end
    end

    # Writes a string to a file
    # @param file [String] path to write to
    # @param text [String] text to write
    #
    module Write
      def write(file:, text:)
        File.open(file, 'w') { |f| f.write text }
      end
    end

    # if args[0] (object) is blank, raises args[1] (message)
    # @param args [Array] - value 1 is obj, value 2 is msg
    #
    module ErrorIfBlank
      def error_if_blank(args)
        obj, msg = args
        obj.blank? && error(msg)
      end
    end

    module M
      # shorter proc shorthands
      def m(*args)
        method(*args)
      end
    end

    # method which does absolutely nothing, ignoring all arguments
    #
    module Nothing
      def nothing(*args)
      end
    end

  end

end
