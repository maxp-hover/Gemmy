# A task to create skeleton structure for a ruby gem
#
# Only one method is intended for public use, {run}.
#
# It takes one argument - the name of the ruby gem.
#
# It then prompts for a few more defails (summary, email, and name).
#
# Here's the structure it creates:
#
# ├── <name>.gemspec
# ├── Gemfile
# ├── reinstall
# ├── bin
#   └── <name>
# └── lib
#   ├── <name>.rb
#   └── version.rb
#
# At which point you can run "gem build" then "gem install"
#
class Gemmy::Tasks::MakeGem

  Gemmy::Patches.class_refinements.each { |r| using r }

  # Builds a skeleton ruby gem.
  # Prompts for some input using gets.chomp
  #
  def self.run(name)
    new.make_gem(name)
  end

  # calls a sequence of commands to build out the gem directory
  #
  def make_gem(name)
    @name = name
    @class_name = name.capitalize

    usage_io
    create_root_dir
    create_lib_dir
    create_version_file
    create_main_file
    gemspec_info_io
    create_gemspec_file
    create_gemfile
    create_reinstall_file
    create_executable
    puts "directory #{name} has been created".yellow
  end

  attr_reader :name, :root_dir, :lib, :version_file, :main_file, :summary,
              :author, :email, :gemspec_file, :class_name, :rubygems_version,
              :gemfile

  private

  # prints usage instructions unless the gem name was specified
  #
  def usage_io
    if @name.blank?
      puts "\nUsage: make_gem <name>"
      exit
    end
    self
  end

  # Creates a root directory for the gem
  #
  def create_root_dir
    @root_dir = name
    `mkdir #{root_dir}`
    puts "created root dir".green
    self
  end

  # creates a lib directory for the gme
  #
  def create_lib_dir
    @lib = "#{root_dir}/lib"
    `mkdir #{lib}`
    puts "created lib dir".green
    self
  end

  # creates a version file for the gem
  #
  def create_version_file
    @version_file = "#{lib}/version.rb"
    version_text = <<-TXT.unindent
      module #{class_name}
        VERSION = '0.0.0'
      end
    TXT
    write file: version_file, text: version_text
    puts "wrote version file".green
    self
  end

  # creates a main file for the gem.
  # this file explicitly requires each of the gem's dependencies.
  #
  def create_main_file
    @main_file = "#{lib}/#{name}.rb"
    main_text = <<-TXT.unindent
      require 'colored'
      require 'pry'
      require 'active_support/all'
      require 'thor'
      module #{class_name}
      end
      Gem.find_files("#{name}/**/*.rb").each &method(:require)
    TXT
    write file: main_file, text: main_text
    puts "wrote main file".green
    self
  end

  # prompts for some additional info required for the gemspec
  #
  def gemspec_info_io
    puts "Some info is needed for the gemspec:".red
    @summary = _prompt "add a one-line summary."
    @author = _prompt "enter the author's name"
    @email = _prompt "enter the author's email"
    @rubygems_version = `gem -v`.chomp
    self
  end

  # creates a gemspec file
  # add gem dependencies here, not the Gemfile
  # the Gemfile contains a reference to this file
  #
  def create_gemspec_file
    @gemspec_file = "./#{root_dir}/#{name}.gemspec"
    gemspec_text = <<-TXT.unindent
      require_relative './lib/version.rb'
      Gem::Specification.new do |s|
        s.name        = name
        s.version     = #{class_name}::VERSION
        s.date        = "#{Time.now.strftime("%Y-%m-%d")}"
        s.summary     = "#{summary}"
        s.description = ""
        s.platform    = Gem::Platform::RUBY
        s.authors     = ["#{author}"]
        s.email       = '#{email}'
        s.homepage    = "http://github.com/maxpleaner/gemmy"
        s.files       = Dir["lib/**/*.rb", "bin/*", "**/*.md", "LICENSE"]
        s.require_path = 'lib'
        s.required_rubygems_version = ">= #{rubygems_version}"
        s.executables = Dir["bin/*"].map &File.method(:basename)
        s.add_dependency "colored", '~> 1.2'
        s.add_dependency 'activesupport', '~> 4.2', '>= 4.2.7'
        s.add_dependency 'pry', '~> 0.10.4'
        s.add_dependency 'thor', '~> 0.19.4'
        s.license     = 'MIT'
      end
    TXT
    write file: gemspec_file, text: gemspec_text
    puts "wrote gemspec".green
    self
  end

  # creates a gemfile which contains a reference to the gemspec
  # in a ruby gem, gems are listed in the gemspec, not the gemfile.
  #
  def create_gemfile
    @gemfile = "./#{root_dir}/Gemfile"
    gemfile_text = <<-TXT.unindent
      source "http://www.rubygems.org"
      gemspec
    TXT
    write file: gemfile, text: gemfile_text
    puts "wrote gemfile".green
    self
  end

  # A reinstall file is very helpful for development
  def create_reinstall_file
    file_txt = <<-TXT.unindent
      #!/usr/bin/env ruby
      Dir.glob("./*.gem").each { |path| `rm \#{path}` }
      puts `gem uninstall -x #{name}`
      puts `gem build #{name}.gemspec`
      Dir.glob("./*.gem").each { |path| puts `gem install -f \#{path}` }
    TXT
    file_path = "#{root_dir}/reinstall"
    File.open(file_path, 'w') do |file|
      file.write file_txt
    end
    `chmod a+x #{file_path}`
    puts "wrote reinstall file".green
  end

  # Creates an empty gem executable which requires the gem.
  # This makes it easy to call functions from the ruby codebase.
  # The Thor CLI library is used, see whatisthor.com
  def create_executable
    file_txt = <<-TXT.unindent
      #!/usr/bin/env ruby
      require '#{name}'
      class #{class_name}::CLI < Thor
        desc "test", "run tests"
        def test
          puts "No tests have been wrritten"
          exit
        end
      end
      #{class_name}::CLI.start ARGV
    TXT
    `mkdir #{root_dir}/bin`
    file_path = "#{root_dir}/bin/#{name}"
    write(file: "#{file_path}", text: file_txt)
    `chmod a+x #{file_path}`
    puts "wrote executable".green
  end

end

