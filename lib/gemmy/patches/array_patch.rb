# Array patches
#
module Gemmy::Patches::ArrayPatch
  # checks if any of the results of an array do not respond truthily
  # to a block
  #
  # For example, to check if any items of an array are truthy:
  #   [false, nil, ''].any_not? &:blank?
  #   => false
  #
  def any_not?(&blk)
    any? { |item| ! blk.call(item) }
  end

  refine Array do
    include Gemmy::Patches::ArrayPatch
  end

end
