# Symbol patches
#
module Gemmy::Patches::SymbolPatch

  # Patch symbol so the proc shorthand can take extra arguments
  # http://stackoverflow.com/a/23711606/2981429
  #
  # Example: [1,2,3].map &:*.with(2)
  # => [2,4,6]
  #
  def with(*args, &block)
    ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
  end

  refine Symbol do
    include Gemmy::Patches::SymbolPatch
  end

end
