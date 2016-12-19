# I have a separate gem called sentence_interpreter.
# The functionality isn't too complex.
# It defines a Verb and Noun 'lexicon' hash which need to
# be populated by the programmer.
# It then reads a sentence, and extracts Verb => Noun phrases
# according to the lexicon.

# Gemmy wrapps sentence_interpreter to auto-populate the lexicon.
# It also uses 'wordpos' (node) and 'engtagger' (ruby)

# Example of tagging a sentence with EngTagger
# (this is used internally by the gem)
#
tagger = EngTagger.new
tagged = tagger.tag "the cat went in the hat and sat"
tagger.get_nouns(tagged) == { "cat" => 1, "hat" => 2 }

# Example of sentence_interpreter usage
# (also used internally by the gem)
#
NounLexicon[:hello] = ->(vn_phrases) { "hello" }
NounLexicon[:world] = ->(vn_phrases) { "world" }
VerbLexicon[:print] = ->(*nouns) { "printing #{nouns.join(" ")}" }
res = SentenceInterpreter.interpret("print hello world").run_commands
res == "printing hello world"

# The functionality for working with language is found in these modules:
#
include Gemmy::Components::Nlp
include Gemmy::Components::WordSpeaker

# There are some persisted caches in place to prevent unnecessary word
# definition lookups. The data stored looks like this:
#
#   sentence => words => part of speech(aka pos)
#
# For this two different caches are used. One stores word=>pos.
# The other contains the entire word=>pos list for a sentence.
# The reason for this is pos detection takes place on both the word
# and sentence level. EngTagger uses the sentence context, and Wordpos uses the
# word context.
#
# The caches are built on PersistedHash defined in patches/hash_patch
# They have a small API:
# get(*keys)
# get_or_set(*keys, &blk)
# set(*keys, val)
# keys
# clear
#
# For the purposes of testing, the caches can be cleared:
#
Gemmy::Components::Cache.new("sentence_pos").clear
Gemmy::Components::Cache.new("word_pos").clear

# There are two additional caches, for the Noun and Verb lexicon.
# Words are only added here if they're unambiguously defined as
# either noun or verb from the engtagger/wordpos results.
#
# The keys are word names and the values are procs.
#
# The proc structure is not externally configurable, but internally it's
# defined like so:
#
# Verb procs are passed a list of nouns in their verb=>noun phrase.
# Actually, it's not the nouns they're passed exactly, it's the results
# of evaluating the noun procs
#
# Noun procs are passed a listing of all the verb=>noun pairs in the sentece.
#
# For testing purposes, these can be cleared:
#
Gemmy::Components::Cache.new("verb_lexicon").clear
Gemmy::Components::Cache.new("noun_lexicon").clear

# Some sample text can be loaded up:
#
arr = File.readlines("/home/max/Documents/max-jabber.txt")

# A longer text can also be used:
# arr = File.readlines("./sample.txt")

# Or a shorter text
# arr = ["this has four words","two words"]

# Gemmy's language API works on a sentence (line) level.
# After 'sanitizing' each line, multiple methods can be called:
#
idxs = []
arr.map(&:nlp_sanitize).each_with_index do |sentence, idx|
    idxs << idx
    puts sentence.green

    # String#syllable_count patch
    puts sentence.syllable_count

    # Speak sentence
    speak_sentence(sentence)

    # Save spoken sentence as WAV file
    speak_sentence(sentence, path: "#{idx}.wav")

    # Run through a sentence, adding words to the lexicon and pos cache
    # Then send it to sentence_interprer to find verb=>noun phrases
    # and run procs.
    puts [parse_sentence(sentence)].run_commands
end

# After creating spoken text WAV files, they can be played in succession
# This uses the Unix util "aplay"
idxs.each { |idx| `aplay #{idx}.wav` }

# For some wackiness, all WAV files can be played at the same using
# by calling aplay in a different thread.
idxs.each { |i| sleep 0.1; Thread.new { `aplay #{i}.wav` } }

#

