module Gemmy::Tests

  module ComponentTests
    def self.run
      Gemmy::Tests.run_test_class DynamicStepsTests
    end
  end

  TestSets << ComponentTests

end