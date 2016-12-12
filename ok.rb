module Patch
  refine Enumerator do
    def patched?
      true
    end
  end
end

class Test
  using Patch
  [].each.patched?
end

