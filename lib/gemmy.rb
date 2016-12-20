require 'awesome_print'
require 'thor'
require 'colored'
require 'active_support/all'
require 'pry'
require 'colored'
require 'corefines'
require 'sentence_interpreter'
require 'engtagger'
require 'odyssey'

# Container class for all the functionality.
#
class Gemmy

  # Slightly friendlier way to reference component classes
  # Gemmy.component("word_speaker/sentence")
  def self.component(path)
    Gemmy::Components.const_get(
      path.split("/").map { |part| part.camelcase }.join("::")
    )
  end

  # Used by patches to get a reference to static patch classes
  # Without this there would be long, unqualified constant names such as
  # Gemmy::Patches::SymbolPatch::InstanceMethods::Call
  #
  # Usage is to pass a string like so: "<CoreClass>/<Context>/<MethodName>"
  # Core class could be "symbol" for example
  # Context is either "i" for instance or "c" for class
  # Method name is underscored, i.e. "call" in this example:
  #
  # klass = Gemmy.patch "symbol/i/call"
  #
  # Now I can call any class methods on the klass.
  #
  # The utility of this might not be obvious, but it is useful
  # when using another library's refinements in Gemmy's own
  def self.patch(string)
    parts = string.split("/")
    raise ArgumentError unless parts.length == 3
    core_class, context, method_name = parts
    context_classname = context.eql?("i") ? "InstanceMethods" : "ClassMethods"
    Gemmy::Patches.const_get("#{core_class.capitalize}Patch")
                  .const_get(context_classname)
                  .const_get method_name.camelcase
  end

  def self.patches(*args)
    Gemmy::Patches.class_refinements *args
  end

  # Get a constant,
  # lookup on Gemmy::Constants
  # it gsubs '/' to '::'
  # and if the given constant names are lowercase,
  # then it camelcases them.
  def self.const(const_name_abbrev)
    const_name = const_name_abbrev.split("/").map do |x|
      x.chars.all? { |char| char.in? 'a'.upto('z') } ? x.camelcase : x
    end.join("::")
    Gemmy::Constants.const_get const_name
  end

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

Gem.find_files("gemmy/**/*.rb").sort_by do |x|
  x.split("/").length
end.each &method(:require)

# Alias for less typing
class Gmy < Gemmy
end
