require 'gemmy'
require 'byebug'

# Patches can be loaded globally:

    # Gemmy.load_globally

    # [].to_enum.method(:map_by)
    # [[]].map(&:push.(1))

# The patches can each be tested (assuming they're loaded globally)
# Not all the patches define a 'autotest' class method though, so coverage
# isn't 100%

    # Gemmy::Patches.autotest

# Breakpoints are a nice way to experiment
# I've found that a breakpoint should not be the last statement in a scope,
# be it file, method, class, enumerator, etc. That's why there's a false
# there at the end, it's just an arbitrary statement

    # binding.pry
    # false

# Test that refinements can be loaded by other refinements

    # module A
    #   using CF::Enumerable[:index_by]
    #   refine Hash do
    #     def index_by *args
    #       super
    #     end
    #   end
    # end

    # module B
    #   using A
    #   [].to_enum.method(:index_by)
    # end

# However this doesn't seem to work when refine is applied dynamically.

# Including another library's refinements in my own proved to be a little
# complex. Here's some tests of that functionality, to make sure it works
# when Gemmy is loaded in a refinements-based approach. Make sure to comment
# out Gemmy.load_globally if testing this.

    # module A
    #   using Gemmy::Patches::EnumeratorPatch::InstanceMethods::MapBy
    #   puts [1].to_enum.map_by { |x| [x,x] } == {1 => [1]}

    #   using Gemmy::Patches::SymbolPatch::InstanceMethods::Call
    #   puts [[]].map(&:push.(1)) == [[1]]
    # end
