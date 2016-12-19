require_relative './lib/gemmy/version.rb'

Gem::Specification.new do |s|
  s.name        = 'gemmyrb'
  s.version     = Gemmy::VERSION
  s.date        = '2016-12-04'
  s.summary     = "Some general ruby language utils, including a gem generator. See http://github.com/maxpleaner/gemmy for more detail"
  s.description = ""
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["max pleaner"]
  s.email       = 'maxpleaner@gmail.com'
  s.homepage    = "http://github.com/maxpleaner/gemmy"
  s.files       = Dir["lib/**/*.rb", "bin/*", "**/*.md", "LICENSE"]
  s.require_path = 'lib'
  s.required_rubygems_version = ">= 1.3.6"
  s.executables = Dir["bin/*"].map &File.method(:basename)
  s.license     = 'MIT'

  # For a ruby gem, dependencies are listed here, not in the Gemfile
  # But the Gemfile loads this list
  s.add_dependency "colored", '~> 1.2'
  s.add_dependency 'activesupport', '~> 4.2', '>= 4.2.7'
  s.add_dependency 'pry', '~> 0.10.4'
  s.add_dependency 'byebug', '~> 9.0.6'
  s.add_dependency 'thor', '~> 0.19.4'
  s.add_dependency 'corefines', '~> 1.9.0'
  s.add_dependency 'sentence_interpreter', '~> 0.0.7'
  s.add_dependency 'awesome_print', '~> 1.7.0'
  s.add_dependency 'engtagger', '~> 0.2.1'
  s.add_dependency 'minitest', '~> 5.10.1'
  s.add_dependency 'odyssey', '~> 0.2.0'
end
