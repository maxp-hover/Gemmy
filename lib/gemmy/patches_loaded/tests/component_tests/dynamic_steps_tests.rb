module Gemmy::Tests::ComponentTests::DynamicStepsTests

  Gemmy::Patches.class_refinements.each { |r| using r }

  def self.run
    runner_class = Class.new
    runner_class.include Gemmy::Components::DynamicSteps
    runner = runner_class.new
    runner.define_step(/(.+) case (.+)/) do |a,b|
      error("failed") unless (a=='test') && (b=='pass')
    end
    puts "  define_step".blue
    runner.step "test case pass"
    begin
      runner.step "test case fail"
    rescue RuntimeError => e
      error("unexpected fail") unless e.message==("failed")
      puts "  step".blue
    end
  end

end
