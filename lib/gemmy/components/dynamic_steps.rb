# Mimics the Cucumber API:
#   {DynamicSteps#step} runs a step
#   {DynamicSteps#define_step} defines a step
#
# The usage is the same as Cucumber:
#
#   define_step /I print (.+) (.+) times/ do |string, n|
#     n.times { print string }
#   end
#
#   step "I print hello 2 times"
#   => 'hellohello'
#
# Like Cucumber, it will raise an error if there is > 1 matching step
# {DynamicSteps::AmbiguousMatchError} can be rescued if desired.
#
# It also raises an error if no matcher was found
#
module Gemmy::Components::DynamicSteps

  Gemmy::Patches.refinements.each { |r| using r }

  # A hash mapping regex to proc
  #
  attr_reader :steps

  # Error raised when a string matches multiple step regexes.
  # It's frequently accidental to come into this situation,
  # and having this check prevents surprise errors.
  #
  class AmbiguousMatchError < StandardError; end

  # Error raised when no matcher is found for a string
  #
  class NoMatchFoundError < StandardError; end

  def steps
    @steps ||= {}
  end

  # Defines a regex => proc mapping
  # A good pattern for regex is to use (.+) as match groups, and
  # mirror those as sequential named parameters in the block.
  #
  # Match groups are left-greedy, for example:
  #   "1 2 3 4 5".match(/(.+) (.+)/).tap &:shift
  #   # => ['1 2 3 4', '5']
  #
  def define_step(regex, &blk)
    steps[regex] = blk
  end

  # run a step.
  # searches @step keys for regex which matches the string
  # then runs the associated proc, passing the regex match results
  #
  def step(string)
    matching_steps = find_matching_steps(string)
    if matching_steps.keys.length > 1
      # Failure, multiple matching steps
      raise(
        AmbiguousMatchError,
        "step #{string} matched: #{matching_steps.keys.join(", ")}"
      )
    elsif matching_steps.keys.length == 0
      # Failure, no matching step
      raise(
        NoMatchFoundError,
        "step #{string} had no match"
      )
    else
      # Success, run the proc
      matching_step = matching_steps.values[0]
      matching_step[:proc].call(*(matching_step[:matches]))
    end
  end

  # Searches the keys in @steps for a regex the matches the string.
  # If one is found, it adds the regex as a key in the results hash.
  # The value is a hash with two keys: :matches (an array) and :proc
  #
  def find_matching_steps(string)
    matching_steps = steps.reduce({}) do |matching_steps, (regex, proc)|
      match_results = string.match(regex).to_a.tap &:shift
      if match_results.any_not? &:blank?
        matching_steps[regex] = { matches: match_results, proc: proc }
      end
      matching_steps
    end
  end

end
