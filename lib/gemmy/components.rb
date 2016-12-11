  # Different collections of functionality
  #
  module Gemmy::Components
    def self.included(base)
      list.each do |klass|
        base.include klass
        base.extend klass
      end
    end

    def self.list
      @@list ||= [
        Gemmy::Components::DynamicSteps
      ]
    end

  end
