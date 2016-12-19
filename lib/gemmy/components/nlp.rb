module Gemmy::Components::Nlp

  Gemmy::Patches.class_refinements.each { |r| using r }


  def parse_sentence sentence
    setup_lexicons
    log_sentence sentence
    begin
      SentenceInterpreter.interpret sentence
    rescue NounBeforeVerbError
      []
    end
  end

  def setup_lexicons
    return if @lexicon_set_up
    Object.send :remove_const, "VerbLexicon"
    Object.send :remove_const, "NounLexicon"
    Object.send(:const_set,"VerbLexicon", Gemmy::Components::Cache.new(
      "verb_lexicon"
    ))
    Object.send(:const_set,"NounLexicon", Gemmy::Components::Cache.new(
      "noun_lexicon"
    ))
    @lexicon_set_up = true
  end

  # Uses the Ruby EngTagger tool to find parts of speech
  # of a sentence
  #
  # Returns a hash with :verbs and :nouns keys (vals are arrays)
  #
  def tag_sentence sentence
    @tagger ||= EngTagger.new
    res = @tagger.add_tags(sentence).ergo do |tagged|
      nouns = @tagger.get_nouns(tagged)&.keys || []
      verbs = @tagger.get_verbs(tagged)&.keys || []
      [nouns, verbs]
    end
  end

  # Adds words in sentence to application database
  # The part of speech is identified by the DB Name
  # Each entry is a word => proc mapping.
  #
  # Noun procs are passed all vn_phrases for the sentence
  # (these are constructed by parse_sentence)
  #
  # The Verb procs are passed the evaluated results of the Noun procs
  # in its Verb-Noun phrase (as sequential arguments)
  #
  # For example, if the phrase is "live well and flourish"
  # Then (assuming the
  #
  # Although EngTagger extracts POS for the words in a sentence,
  # these classifications are context-dependent.
  #
  # For this reason, words are also looked up using WordPos.
  # Only umambiguous words are added to the grammar.
  #
  def log_sentence sentence
    sentence_cache.get_or_set(sentence) do
      engtagger_lookup(sentence).map do |word, pos|
        finalize_pos(word, pos)
      end
    end
  end

  # Compare WordPos and Engtagger results and save to proc if found
  # only prioritize Engtagger if WordPos is missing
  def finalize_pos word, pos
    final_pos = word_pos_cache.get_or_set(word) do
      doublecheck = wordpos_lookup(word)
      if ['noun', 'verb'].none? &doublecheck.m(:include?)
        finalize_engtagger_pos(pos)
      else
        finalize_wordpos_pos(pos)
      end
    end
    save_proc(final_pos, word)
    { word: word, pos: [final_pos] }
  end

  def finalize_engtagger_pos(pos)
    # If the WordPos definition isn't found, then there's no ambiguity
    if pos.include?("noun")
      "noun"
    elsif pos.include?("verb")
      "verb"
    else
      "unknown"
    end
  end

  def finalize_wordpos_pos(pos)
    # WordPos returns ambiguous results.
    # Only unambiguous words are selected.
    # I.e. a noun|verb isn't saved.
    # It must be solely noun or verb.
    if pos.include?("noun") && !pos.include?("verb")
      "noun"
    elsif pos.include?("verb") && !pos.include?("noun")
      "verb"
    else
      "unknown"
    end
  end

  def save_proc(final_pos, word)
    if final_pos.include?("noun")
      save_noun_proc(word)
    elsif final_pos.include?("verb")
      save_verb_proc word
    end
  end

  def save_noun_proc word
    NounLexicon.set word.to_sym, default_noun_proc_string(word)
  end

  def save_verb_proc word
    VerbLexicon.set word.to_sym, default_verb_proc_string(word)
  end

  def default_noun_proc_string(word)
    <<-Ruby.strip_heredoc
      ->(vn_phrases){ "#{word}" }
    Ruby
  end

  def default_verb_proc_string(word)
    <<-Ruby.strip_heredoc
      ->(*nouns){ "#{word} \#{nouns.join " "}" }
    Ruby
  end

  # This uses EngTagger to analyze a sentence
  # The results will not be ambiguous; in this method's results,
  # a given word with either be 'verb', 'noun', or 'unknown'.
  def engtagger_lookup sentence
    nouns, verbs = tag_sentence(sentence)
    sentence.words.graph do |word|
      pos = case word
      when ->(w){ verbs.include? w }
        "verb"
      when ->(w){ nouns.include? w }
        "noun"
      else
        "unknown"
      end
      [word, [pos]]
    end
  end

  # Engtagger evaluates POS in the context of a sentence
  # So from that perspective, only entire sentences can be cached
  def sentence_cache
    @sentence_cache ||= Gemmy::Components::Cache.new "sentence_pos"
  end

  # This cache reduces the call rate of the WordPos shell util
  # by caching the POS for individual words.
  def word_pos_cache
    @pos_cache ||= Gemmy::Components::Cache.new("word_pos")
  end

  def wordpos_lookup(word)
    default_result = ['unknown']
    result = []
    word = word.strip.gsub(/[^a-zA-z]/, '')
    return default_result if word.empty?
    pos_response = JSON.parse `coffee -e "#{Gemmy::Coffee}" pos #{word}`
    result << "verb" unless pos_response["verbs"].empty?
    result << "noun" unless pos_response["nouns"].empty?
    result.empty? ? default_result : result
  end

end
