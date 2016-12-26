require 'gemmy'
require 'byebug'

# Patches can be loaded globally:

    Gemmy.load_globally

    # [].to_enum.method(:map_by)
    # [[]].map(&:push.(1))

# The patches can each be tested (assuming they're loaded globally)
# Not all the patches define a 'autotest' class method though, so coverage
# isn't 100%

    # Gemmy::Patches.autotest

# Breakpoints are a nice way to experiment
# I've found that a breakpoint should not be the last statement in a scope,
# be it file, method, class, enumerator, etc. That's why there's a false
# there at the end, it's just an arbitrary statement

    # binding.pry
    # false

# Test that refinements can be loaded by other refinements

    # module A
    #   using CF::Enumerable[:index_by]
    #   refine Hash do
    #     def index_by *args
    #       super
    #     end
    #   end
    # end

    # module B
    #   using A
    #   [].to_enum.method(:index_by)
    # end

# However this doesn't seem to work when refine is applied dynamically.

# Including another library's refinements in my own proved to be a little
# tricky. Here's some tests of that functionality, to make sure it works
# when Gemmy is loaded in a refinements-based approach. Make sure to comment
# out Gemmy.load_globally if testing this.

    # module A
    #   using Gemmy.patch "enumerator/i/map_by"
    #   puts [1].to_enum.map_by { |x| [x,x] } == {1 => [1]}

    #   using Gemmy.patch "symbol/i/call"
    #   puts [[]].map(&:push.(1)) == [[1]]
    # end

# Verb-Noun phrases can be detected using a separate gem I made called
# sentence_interpreter.
#
# The entire lexicon needs to be added, which is where
# the Node lib 'wordpos' and the Ruby lib 'engtagger' come in.

    # sentence = "the cat went in the hat, sat, and was fat"
    # tagged = EngTagger.new.add_tags(sentence)
    # words = {}.persisted("dictionary.yml")
    # words.set(:nouns, {}.autovivified)
    # words.set(:verbs, {}.autovivified)

    # NounLexicon[:hello] = ->(vn_phrases) { "hello" }
    # NounLexicon[:potato] = ->(vn_phrases) { "potato" }
    # VerbLexicon[:print] = ->(*noun_results) { puts noun_results.join }
    # SentenceInterpreter.interpret("print hello potato").run_commands

# Part of speech tagger
#
include Gemmy::Components::Nlp
include Gemmy::Components::WordSpeaker

# Gemmy::Components::Cache.new("sentence_pos").clear
# Gemmy::Components::Cache.new("word_pos").clear
# Gemmy::Components::Cache.new("verb_lexicon").clear
# Gemmy::Components::Cache.new("noun_lexicon").clear

# arr = File.readlines("/home/max/Documents/max-jabber.txt")

# arr = File.readlines("./sample.txt")

# arr = [
#     "this has four words",
#     "two words"
# ]

# `rm wav/*.wav`

# idxs = []

# arr = arr.map(&:nlp_sanitize)
# .reject(&:blank?)
# .first(2)

# arr = [
# "free",
# "the cat in the hat"
# ]

# arr.each_with_index do |sentence, idx|
    # idxs << idx
    # puts sentence.green
#     puts sentence.syllable_count
    # speak_sentence(sentence)
#     # puts [parse_sentence(sentence)].run_commands
# end

# 8.times do
#     idxs.each do |i|
#         Thread.new do
#             if File.exists? "wav/#{i}.wav"
#                 `aplay wav/#{i}.wav`
#             end
#         end
#         sleep 0.6
#     end
# end

# tracks = {
#     free: "wav/free.wav",
#     cat_in_hat: "wav/cat_in_hat.wav",
#     amen: "wav/amen.wav"
# }.to_ostruct

# speak_sentence(
#     sentence: "free",
#     syllables: 1,
#     syllable_length: 6.4,
#     path: tracks.free,
#     cached: true,
#     silent: true
# )

# speak_sentence(
#     sentence: "the cat in the hat",
#     syllables: 1,
#     syllable_length: 1.75,
#     path: tracks.cat_in_hat,
#     cached: true,
#     silent: true
# )

# Thread.new do
#     loop do
#         `play wav/drone.wav`
#     end
# end

# Thread.new do
#     16.times do
#         Thread.new do
#             2.times { Thread.new { `aplay #{tracks.free}` } }
#             `aplay #{tracks.cat_in_hat}`
#             `aplay #{tracks.cat_in_hat}`
#             `aplay #{tracks.cat_in_hat}`
#             `aplay #{tracks.cat_in_hat}`
#         end
#         2.times do
#             Thread.new do
#                 `aplay #{tracks.amen}`
#             end
#         end
#         sleep 7.0
#     end
# end.join



