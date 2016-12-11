# Gemmy provides patches for a few of the core classes.
#
# Use Gemmy#load_globally to load these on the root namespace
# For a refinements-based approach, use this in a class/module definition:
#
# Gemmy::Patches.class_refinements.each { |klass| using klass }
#
# Note that there are nuances for how refinements are used.
# You can't refer to the patches using define_method, for example.
#
# See examples/01_using_as_refinement.rb for more info
# (linked from the README at github.com/maxpleaner/gemmy
#
module Gemmy::Patches

  # The usage of this method is to load all the patches for some core classes.
  # With no arguments it will include all patches
  # There are two optional params (keyword arguments).
  # @param only [Array<Symbol>] if provided, will only patch those classes
  # @param except [Array<Symbol>] if provided, will exclude those classes
  # @return [Array<Class>] to be iteratively passed to 'using'
  def self.class_refinements(only: nil, except: nil)
    return @@refined if defined? @@refined
    @@refined = core_patches.reduce([]) do |arr, (core_klass_sym, patch_klass)|
      next if only && !only.include?(core_klass_sym)
      next if except && except.include?(core_klass_sym)
      core_klass = const_get core_klass_sym.to_s
      class_patches = patch_klass.const_get "ClassMethods"
      instance_patches = patch_klass.const_get "InstanceMethods"
      class_patches.constants.each do |patch_class_sym|
        patch_class = class_patches.const_get patch_class_sym
        patch_as_class_method(core_klass, patch_class)
        arr.push patch_class
      end
      instance_patches.constants.each do |patch_class_sym|
        patch_class = instance_patches.const_get patch_class_sym
        patch_as_instance_method(core_klass, patch_class)
        arr.push patch_class
      end
      arr
    end.compact
    @@refined
  end

  # Cherry pick methods to patch.
  # @param hash [Hash] with a particular structure:
  #   top level keys are Symbols referring to core classes, i.e. :String
  #   top level values are hashes.
  #   second level keys are either :ClassMethods or :InstanceMethods
  #                                referring to the scope
  #   second level values are arrays of symbols (one per method)
  #
  # To give an example:
  #
  #   Gemmy::Patches.method_refinements(
  #     Array: { InstanceMethods: [:Recurse, :KeyBy] }
  #   ).each { |r| using r }
  #
  def self.method_refinements(hash)
    hash.map do |core_klass_sym, patch_types|
      core_class = const_get(core_klass_sym)
      patch_types.map do |type_sym, patch_method_syms|
        patch_methods = core_patches[core_klass_sym].const_get type_sym.to_s
        patch_method_syms.map do |patch_method_sym|
          method_class = patch_methods.const_get(patch_method_sym)
          if type_sym == :InstanceMethods
            patch_as_instance_method(core_class, method_class)
          elsif type_sym == :ClassMethods
            patch_as_class_method(core_class, method_class)
          end
          method_class
        end
      end
    end.flatten.compact
  end

  def self.patch_as_class_method(core_klass, patch_klass)
    patch_klass.send(:refine, core_klass.singleton_class) do
      include patch_klass
    end
  end

  def self.patch_as_instance_method(core_klass, patch_klass)
    patch_klass.send(:refine, core_klass) do
      include patch_klass
    end
  end

  def self.core_patches
    @@core_patches ||= {
      String: Gemmy::Patches::StringPatch,
      Symbol: Gemmy::Patches::SymbolPatch,
      Object: Gemmy::Patches::ObjectPatch,
      Array: Gemmy::Patches::ArrayPatch,
      Method: Gemmy::Patches::MethodPatch,
      Hash: Gemmy::Patches::HashPatch,
      Thread: Gemmy::Patches::ThreadPatch,
      Integer: Gemmy::Patches::IntegerPatch
    }.with_indifferent_access
  end

end
