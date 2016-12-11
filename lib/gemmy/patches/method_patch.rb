# Method patches. To the 'Method' class i.e. `method(:puts)`
#
module Gemmy::Patches::MethodPatch

  module ClassMethods
  end

  module InstanceMethods

    # Bind an argument to a method.
    # Very useful for the proc shorthand.
    # For example say there's a method "def add(a,b); print a + b; end"
    # You can run it for each number in a list:
    #    [1,2,3].each &method(:add).bind(1)
    #    => 234
    #
    module Bind
      def bind *args
        Proc.new do |*more|
          self.call *(args + more)
        end
      end
    end

  end

end
