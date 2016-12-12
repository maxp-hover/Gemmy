module Gemmy::Patches::ExceptionPatch

  module ClassMethods

    module Raised
      # facets
      # does an exception raise an error?
      def self.raised? #:yeild:
        begin
          yield
          false
        rescue self
          true
        end
      end
    end

    module Suppress
      # facets
      def suppress(*err_classes)
        err_classes.each do |e|
          unless e < self
            raise ArgumentError, "exception #{e} not a subclass of #{self}"
          end
        end
        err_classes = err_classes.empty? ? [self] : err_classes
        begin
          yield
        rescue Exception => e
          raise unless err_classes.any? { |cls| e.kind_of?(cls) }
        end
      end
    end

  end

  module InstanceMethods
  end

end
