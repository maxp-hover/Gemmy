# Method patches. To the 'Method' class i.e. `method(:puts)`
#
module Gemmy::Patches::MethodPatch

  # Bind an argument to a method.
  # Very useful for the proc shorthand.
  # For example say there's a method "def add(a,b); print a + b; end"
  # You can run it for each number in a list:
  #    [1,2,3].each &method(:add).bind(1)
  #    => 234
  #
  def bind *args
    Proc.new do |*more|
      self.call *(args + more)
    end
  end

  refine Method do
    include Gemmy::Patches::MethodPatch
  end

end
