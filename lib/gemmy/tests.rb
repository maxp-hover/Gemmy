# Test out the gem
# Can be called from the command line: gemmy test
#
module Gemmy::Tests
  TestSets = []

  def self.run
    TestSets.each &method(:run_test_class)
  end

  def self.run_test_class(klass)
    klass.run
    # Unless a test raises an error, it's been run
    puts "#{klass} passed".green
  end

end
