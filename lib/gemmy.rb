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
    core_patches = Patches.core_patches.map do |core_klass_name, patch_klass|
      core_klass = core_klass_name.to_s.constantize
      instance_method_class = patch_klass.const_get("InstanceMethods")
      class_method_class = patch_klass.const_get("ClassMethods")
      instance_classes = instance_method_class.constants.map do |klass_sym|
        klass = instance_method_class.const_get klass_sym
        core_klass.include klass
        klass
      end
      class_classes = class_method_class.constants.map do |klass_sym|
        klass = class_method_class.const_get klass_sym
        core_klass.extend klass
        klass
      end
      [instance_classes, class_classes]
    end
    components = Components.list.map do |patch_klass|
      Object.include patch_klass
      Object.extend patch_klass
      patch_klass
    end
    [components, core_patches].flatten
  end
end

# Load files in order of their "/" count
# to preserve constant hierarchies
#
Gem.find_files("gemmy/**/*.rb").sort_by do |x|
  x.split("/").length
end.each &method(:require)

