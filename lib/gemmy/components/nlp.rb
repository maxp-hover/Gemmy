module Gemmy::Components::Nlp

  Gemmy::Patches.class_refinements.each { |r| using r }

  Object.send :remove_const, "VerbLexicon"
  Object.send :remove_const, "NounLexicon"
  Object.send :const_set, "VerbLexicon", {}.persisted("verb_lexicon.pstore")
  Object.send :const_set, "NounLexicon", {}.persisted("noun_lexicon.pstore")

  def parse_sentence sentence
    sentence = sentence.downcase
    log_sentence sentence
    SentenceInterpreter.interpret sentence
  end

  def log_sentence sentence
    sentence.words.to_enum.graph do |word|
      [word, parts_of_speech(word)]
    end.map do |word, pos|
      # If there's ambiguity (a matching verb and noun), use the noun
      pos.delete('v') if ['n', 'v'].all? &pos.method(:include?)
      pos.each do |type|
        if type == "n"
          NounLexicon.set word.to_sym, <<-PROC_STRING.strip_heredoc
            ->(vn_phrases){ "#{word}-noun" }
          PROC_STRING
        elsif type == "v"
          VerbLexicon.set word.to_sym, <<-PROC_STRING.strip_heredoc
            ->(*nouns){ "#{word}-verb" }
          PROC_STRING
        end
      end
      { word: word, pos: pos }
    end
  end

  def parts_of_speech(word)
    ["verb", "noun"].flat_map do |word_type|
      `wordpos def --#{word_type} #{word}`.split("\n").map do |line|
        if line.starts_with? "  "
          line.split("  ")[1].split(": ")[0]
        end
      end.compact.uniq
    end
  end

end
