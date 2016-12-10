require 'thor'
require 'colored'
require 'active_support/all'
require 'pry'
require 'colored'

# Container class for all the functionality.
#
class Gemmy

  # There are two main usages:
  #   - namespaced (using refinements and explicit include/extend calls)
  #   - global
  #
  # This is the method handling the global case
  #
  def self.load_globally
    Patches.core_patches.each do |core_klass_name, patch_klass|
      core_klass_name.to_s.constantize.include patch_klass
    end
    Components.list.each do |patch_klass|
      Object.include patch_klass
      Object.extend patch_klass
    end
  end
end

# Load files in order of their "/" count
# to preserve constant hierarchies
#
Gem.find_files("gemmy/**/*.rb").sort_by do |x|
  x.split("/").length
end.each &method(:require)

