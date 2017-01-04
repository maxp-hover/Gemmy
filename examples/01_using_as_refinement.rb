# Gemmy provides some patches to core Ruby
# There are two ways to include them: as refinements, or globally.

# As refinements, they will only exist within a certain scope.
# The keywords 'using' and 'refine' appeared in ruby 2.0.
# 'using' in particular has some limitations, but it's the only way I've found
# to restrict the scope of patches.

# Firsly, 'using' cannot be abstracted into any method.
# It must be called from the top-level scope in a module/class,
# and it cannot be invoked dynamically.

# Despite this, 'using' is not all that bad. It makes the patch methods
# available to both class and instance scopes without any further code.
# It accepts a variable for it's classname argument and can be invoked in a 
# loop as well. With that in mind, this is the best I could do:

class Tester
  Gemmy::Patches.class_refinements.each { |r| using r }
  nothing.eql?(nil) # Object#nothing patch
  def self.refined?
    new.refined?
  end
  def refined?
    nothing.nil? # does a bear shit in the woods?
  end
end

# Secondly, the patched matcheds can't be used outside of their original method
# definitions. That is to say, they can't be used with define_method or
# referenced in a block passed as an argument. The one exception I found is
# 'eval', but a wrapper method must be explicitly written.

# All the following will raise errors because of the way 'using' works:

nothing.eql?(nil)                             rescue "error was expected"
Tester.class.send(:eval, "nothing.eql?(nil)") rescue "error was expected"
Tester.send(:eval, "nothing.eql?(nil)")       rescue "error was expected"
Tester.define_singleton_method(:test_method) { nothing.eql?(nil) }
Tester.test_method                            rescue "error was expected"

# Passed blocks also can't access the refined methods:

class Tester
  Gemmy::Patches.class_refinements.each { |r| using r }
  def self.call_block(&blk)
    blk.call
  end
end

Tester.call_block { nothing.eql?(nil) } rescue "error was expected"

# Eval does work if it's not invoked with 'send':

class Tester
  Gemmy::Patches.class_refinements.each { |r| using r }
  def self.call_eval(string)
    eval string
  end
end

Tester.call_eval %{
  nothing.eql?(nil)
}

# Other than the core object patches, some other methods can be loaded onto the
# top level scope. When using refinements, this requires a call to
# include or extend.

class Tester
  include Gemmy::Components

  # These are methods from Gemmy::Components::DynamicSteps
  define_step(/(.+)/) { |x| "you said #{x}" }
  step "hello" # => you said hello
end

# The reason all this is mentioned is that it's not necessary when Gemmy's
# patches are applied globally. In that case, the components include/extend
# happens automatically.

# Patches can also be cherrypicked for use with refinements.
# In the application's internal structure, this required wrapping all
# patch methods in their own modules.

# There's a method "Gemmy::Patches.method_refinements" that will replace
# "Gemmy::Patches.class_refinements" in this case. It's argument is a
# hash with special syntax:

class Tester
  Gemmy::Patches.method_refinements(
    String: { InstanceMethods: [:Unindent] },
    Array: { InstanceMethods: [:Recurse, :AnyNot] }
  ).each { |klass| using klass }

  def self.refined?
    new.refined?
  end
  def refined?
    # showing a few methods being used
    "  hello\n   world".unindent == "hello\nworld" # true
    [nil, [nil]].recurse(&:compact).any_not? { |x| !!x } # false

    # other patches aren't defined
    defined? nothing # false
  end
end

# There's also a shortcut to cherrypicking a few modules:

Gemmy.patch("symbol/i/call") ==\
Gemmy::Patches::SymbolPatch::InstanceMethods::Call

Gemmy.patch("array/c/wrap") == \
Gemmy::Patches::ArrayPatch::ClassMethods::Wrap

# You can do something like:

module Test
  using Gemmy.patch("symbol/i/call")
  [[]].map(&:push.(1)) == [[1]]
end
