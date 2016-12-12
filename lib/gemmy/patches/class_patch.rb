module Gemmy::Patches::ClassPatch
  module InstanceMethods
    module ToProc
      # facets
      # I.e if an initializer takes one arg, then you can do
      # %w{ arg1 arg2 }.map &ClassToInitialize
      def to_proc
        proc{|*args| new(*args)}
      end
    end
  end
  module ClassMethods
  end
end
