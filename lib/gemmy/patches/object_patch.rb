# Object patches. Can be called with implicit receiver
#
module Gemmy::Patches::ObjectPatch

  # Turns on verbose mode, showing warnings
  #
  def verbose_mode
    $VERBOSE = true
  end

  # Generic error. Raises RuntimeError
  # @param msg [String] optional
  #
  def error(msg='')
    raise RuntimeError, msg
  end

  # Prints a string then gets input
  # @param txt [String]
  #
  def _prompt(txt)
    puts txt
    gets.chomp
  end

  # Shifts one ARGV and raises a message if it's undefined.
  # @param msg [String]
  #
  def get_arg_or_error(msg)
    ([ARGV.shift, msg].tap &method(:error_if_blank)).shift
  end

  # Writes a string to a file
  # @param file [String] path to write to
  # @param text [String] text to write
  #
  def write(file:, text:)
    File.open(file, 'w', &:write.with(text))
  end

  # if args[0] (object) is blank, raises args[1] (message)
  # @param args [Array] - value 1 is obj, value 2 is msg
  #
  def error_if_blank(args)
    obj, msg = args
    obj.blank? && error(msg)
  end

  # shorter proc shorthands
  #
  alias m method

  # method which does absolutely nothing, ignoring all arguments
  #
  def nothing(*args)
  end

  refine Object do
    include Gemmy::Patches::ObjectPatch
  end

end
