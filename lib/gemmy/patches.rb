# Gemmy provides patches for a few of the core classes.
#
# See {Gemmy#load_globally} for how to load these on the root namespace
# For a refinements-based approach, use this in a class/module definition:
#
# Gemmy::Patches.refinements.each { |klass| using klass }
#
# Note that there are nuances for how refinements are used. You can't refer to
# the patches using define_method, for example.
#
# See examples/01_using_as_refinement.rb for more info
#
module Gemmy::Patches

  def self.refinements(only: nil, except: nil)
    core_patches.select do |core_klass, patch_klass|
      return false if only && !only.include?(core_klass)
      return false if except && except.include?(core_klass)
      true
    end.values
  end

  def self.core_patches
    @@core_patches ||= {
      String: Gemmy::Patches::StringPatch,
      Symbol: Gemmy::Patches::SymbolPatch,
      Object: Gemmy::Patches::ObjectPatch,
      Array:   Gemmy::Patches::ArrayPatch,
      Method: Gemmy::Patches::MethodPatch,
      Hash:     Gemmy::Patches::HashPatch,
      Thread: Gemmy::Patches::ThreadPatch,
    }.with_indifferent_access
  end

end
