require_relative './lib/gemmy/version.rb'

Gem::Specification.new do |s|
  s.name        = 'gemmy'
  s.version     = Gemmy::VERSION
  s.date        = '2016-12-04'
  s.summary     = "general utils"
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
  s.add_dependency "colored", '~> 1.2'
  s.add_runtime_dependency 'activesupport', '~> 4.2', '>= 4.2.7'
  s.add_runtime_dependency 'pry', '~> 0.10.4

end