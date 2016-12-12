module Gemmy::Patches::ProcPatch
  module ClassMethods
  end
  module InstanceMethods

    module ToMethod
      # facets
      # converts a proc to a method on an object
      # object = Object.__new__
      # function = lambda { |x| x + 1 }
      # function.to_method(object, 'foo')
      # object.foo(1)  #=> 2
      def to_method(object, name=nil)
        ##object = object || eval("self", self)
        block, time = self, Time.now
        method_name = name || "__bind_#{time.to_i}_#{time.usec}"
        begin
          object.singleton_class.class_eval do
            define_method(method_name, &block)
            method = instance_method(method_name)
            remove_method(method_name) unless name
            method
          end.bind(object)
        rescue TypeError
          object.class.class_eval do
            define_method(method_name, &block)
            method = instance_method(method_name)
            remove_method(method_name) unless name
            method
          end.bind(object)
        end
      end
    end

    # facets
    # can be used for higher-order methods
    # a = lambda { |x| x + 4 }
    # b = lambda { |y| y / 2 }

    # (a * b).call(4)  #=> 6
    # (b * a).call(4)  #=> 4
    module Multiply
      def *(x)
        if Integer===x
          # collect times
          c = []
          x.times{|i| c << call(i)}
          c
        else
          # compose procs
          lambda{|*a| self[x[*a]]}
        end
      end
    end

    module Compose
      # facets
      # similar to multiply
      #
      # a = lambda { |x| x + 4 }
      # b = lambda { |y| y / 2 }

      # a.compose(b).call(4)  #=> 6
      # b.compose(a).call(4)  #=> 4
      def compose(g)
        raise ArgumentError, "arity count mismatch" unless arity == g.arity
        lambda{ |*a| self[ *g[*a] ] }
      end
    end

    module BindTo
      # facets
      # a = [1,2,3]
      # p1 = Proc.new{ join(' ') }
      # p2 = p1.bind_to(a)
      # p2.call  #=> '1 2 3'
      def bind_to(object)
        Proc.new{object.instance_eval(&self)}
      end
    end

  end
end
