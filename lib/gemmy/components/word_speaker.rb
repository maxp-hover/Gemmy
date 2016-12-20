module Gemmy::Components::WordSpeaker

  Gemmy.patches.each { |x| using x }

  def speak_sentence(*args)
    sentence = Gemmy.component("word_speaker/sentence").new(*args)
    sentence.save_to_file.speak_file
  end

  class Sentence

    DefaultPitch = 1
    DefaultSpeed = 250
    DefaultGap = 10

    %i{
      sentence
      sentence_syllables
      syllables
      syllable_length
      path
      word_paths
      total_len
      cached
      silent
      idx
    }.each &m(:attr_accessor)

    def initialize(
      sentence:, syllables: 8, syllable_length: 0.2, path: nil, cached: false,
      silent: false
    )
      @sentence = sentence
      @sentence_syllables = @sentence.syllable_count.to_f
      @syllables = syllables.to_f
      @path = path
      @syllable_length = syllable_length.to_f
      @total_len = syllable_length * @syllables
      @cached = cached
      @silent = silent
      @idx = 0
    end

    def save_to_file
      return self if @sentence.empty? || cached
      `espeak -v english-us -w #{path} "#{sentence}"`
      sentence_len = `soxi -D #{path}`.to_f
      diff = 1 / (total_len / sentence_len)
      tmp_path = "wav/tmp.wav"
      `sox #{path} #{tmp_path} tempo #{diff.round(2)}`
      `rm #{path}`
      `mv #{tmp_path} #{path}`
      self
    end

    def speak_file
      return self if @sentence.empty? || silent
      `aplay #{path}`
      self
    end

  end

end
