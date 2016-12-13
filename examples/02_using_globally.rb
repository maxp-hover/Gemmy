# god-mode or lazy-mode? You decide.

# Gemmy's patches and components can be loaded onto the topmost scope
# using a single method call:

Gemmy.load_globally

# Call some test methods
''.unindent
nothing.nil?

# It's also possible to cherrypick patches to be applied globally,

# Usage looks identical to the refinement approach except that 'include'
# replaces 'using':

# Load all Hash patches
Gemmy::Patches.class_refinements(only: [:Hash]).each { |r| include r }

# Load cherrypicked patches
Gemmy::Patches.method_refinements(
  String: { InstanceMethods: [:Unindent] },
  Array: { InstanceMethods: [:Recurse, :AnyNot] }
).each { |klass| include klass }

# Another way to cherrypick patches

include Gemmy.patch("string/i/words")
include Gemmy.patch("symbol/i/call")

"a b c".words == ["a","b","c"]
[[]].map(&:push.(1)) == [[1]]

