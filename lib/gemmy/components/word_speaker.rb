module Gemmy::Components::WordSpeaker
  Gemmy.patches.each { |x| using x }
  def speak_sentence(sentence)
    byebug
    false
  end
end
