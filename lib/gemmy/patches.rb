# Gemmy provides patches for a few of the core classes.
#
# For example:
#   Gemmy::Patches.load(only: [:string])
#   Gemmy::Patches.load(except: [:symbol, :global])
#
module Gemmy::Patches

  def self.refinements
    core_patches.values
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
    }
  end

end
