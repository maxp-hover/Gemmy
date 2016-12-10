# Thread patches
# This does some core configuration to Thread as soon as the patches are
# included, so functionality will be changed even without calling any of these
# methods
#
module Gemmy::Patches::ThreadPatch

  # Ensure that threads bubble up their errors
  #
  def self.included(base)
    Thread.abort_on_exception = true
  end

  refine Thread do
    include Gemmy::Patches::ThreadPatch
  end

end
