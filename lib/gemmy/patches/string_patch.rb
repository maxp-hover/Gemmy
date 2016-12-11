# String patches
#
module Gemmy::Patches::StringPatch

  module ClassMethods
  end

  module InstanceMethods

    # reference 'strip_heredoc' (provided by active support) by 'unindent'
    #
    # this takes an indented heredoc and treats it as if the first line is not
    # indented.
    #
    # Instead of using alias, a method is defined here to enable modular
    # patches
    #
    module Unindent
      def unindent
        strip_heredoc
      end
    end

  end

end
