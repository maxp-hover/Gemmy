# Object patches. Can be called with implicit receiver
#
module Gemmy::Patches::ObjectPatch

  module ClassMethods
  end

  module InstanceMethods

    # Turns on verbose mode, showing warnings
    #
    module VerboseMode
      def verbose_mode
        $VERBOSE = true
      end
    end

    # Generic error. Raises RuntimeError
    # @param msg [String] optional
    #
    module Error
      def error(msg='')
        raise RuntimeError, msg
      end
    end

    # Prints a string then gets input
    # @param txt [String]
    #
    module Prompt
      def _prompt(txt)
        puts txt
        gets.chomp
      end
    end

    # Shifts one ARGV and raises a message if it's undefined.
    # @param msg [String]
    #
    module GetArgOrError
      def get_arg_or_error(msg)
        ([ARGV.shift, msg].tap &method(:error_if_blank)).shift
      end
    end

    # Writes a string to a file
    # @param file [String] path to write to
    # @param text [String] text to write
    #
    module Write
      def write(file:, text:)
        File.open(file, 'w') { |f| f.write text }
      end
    end

    # if args[0] (object) is blank, raises args[1] (message)
    # @param args [Array] - value 1 is obj, value 2 is msg
    #
    module ErrorIfBlank
      def error_if_blank(args)
        obj, msg = args
        obj.blank? && error(msg)
      end
    end

    module M
      # shorter proc shorthands
      def m(*args)
        method(*args)
      end
    end

    # method which does absolutely nothing, ignoring all arguments
    #
    module Nothing
      def nothing(*args)
      end
    end

  end

end
