module Gemmy::Components::WordSpeaker
  include ESpeak

  Gemmy.patches.each { |x| using x }

  def speak_sentence(sentence, container_length=8, path: nil)
    Gemmy::Components::WordSpeaker::Sentence.new(
      sentence,
      container_length,
    ).speak(path: path)
  end

  class Sentence

    DefaultPitch = 1
    DefaultSpeed = 250
    DefaultGap = 10

    %i{
      sentence
      sentence_syllables
      container_length
    }.each &m(:attr_reader)

    def initialize(sentence, container_length)
      @sentence = sentence
      @sentence_syllables = @sentence.syllable_count.to_f
      @container_length = container_length.to_f
    end

    def speak(path: nil)
      pitch = DefaultPitch * diff_multiplier
      speed = DefaultSpeed * diff_factor
      gap = DefaultGap * diff_multiplier
      espeak_opts = "-v english-us -p #{pitch} -s #{speed}"
      if path
        espeak_opts += " -w #{path}"
      end
      `espeak #{espeak_opts} "#{sentence}"`
    end

    def diff_factor
      sentence_syllables / container_length
    end

    def diff_multiplier
      1.0 / diff_factor
    end

  end

end
