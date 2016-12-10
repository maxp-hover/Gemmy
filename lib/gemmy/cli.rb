# Command line interface
#
# Run from command line:
#   gemmy <arguments>
#   e.g. gemmy help
#
# Start from code with Gemmy::CLI.run
#
class Gemmy::CLI < Thor

  # Start the CLI
  # @param arguments [Array<String>] passed to thor, defaults to ARGV
  #
  def self.run(arguments: nil)
    # Store a copy of the arguments.
    # The originals are shifted so they don't intefere with gets
    arguments ||= ARGV.clone
    ARGV.clear

    # Can't make this conditional on "__FILE__ == $0"
    # Because of the way gem executables are run
    start arguments
  end

  # Task to make a gem
  # @param name [String] the name of the gem
  # Other options are requested via gets
  #
  desc "make_gem NAME", "make a skeleton ruby gem project"
  def make_gem(name)
    Gemmy::Tasks::MakeGem.run(name)
  end

  # Test the gem.
  #
  desc "test", "test the gem"
  def test
    Gemmy::Tests.run
  end

end
