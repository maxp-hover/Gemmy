# String patches
#
module Gemmy::Patches::StringPatch

  # reference 'strip_heredoc' (provided by active support) by 'unindent'
  #
  # this takes an indented heredoc and treats it as if the first line is not
  # indented.
  #
  # Instead of using alias, a method is defined here to enable modular
  # patches
  #
  def unindent
    strip_heredoc
  end

  refine String do
    include Gemmy::Patches::StringPatch
  end

end
