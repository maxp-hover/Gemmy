# Patch symbol so the proc shorthand can take extra arguments
# http://stackoverflow.com/a/23711606/2981429
class Symbol
  def with(*args, &block)
    ->(caller, *rest) { caller.send(self, *rest, *args, &block) }
  end
end

module Gemmy
  module ShellScriptLib
    def get_arg_or_error(msg)
      ([ARGV.shift, msg].tap &method(:error_if_blank)).shift
    end
    def write(file:, text:)
      File.open(file, 'w', &:write.with(text))
    end
    private
    def error_if_blank(args)
      obj, msg = args
      obj.blank? && raise(msg)
    end
  end
end