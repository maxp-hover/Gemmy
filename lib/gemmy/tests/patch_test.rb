module Gemmy::Tests

  module PatchTests

    def self.run
      # call each of the patch_class methods
      %i{
        array_test symbol_test method_test thread_test
        global_test string_test hash_test
      }.each { |method_name| PatchedClass.send method_name }
    end

    module Error
      # Allow using raise with one argument only
      # raises RuntimeError
      #
      # this is included in the global patches,
      # but the test suite doesn't depend on it.
      #
      # @param msg [String]
      #
      def error(msg='')
        raise(RuntimeError, msg)
      end
    end

    class PatchedClass

      Gemmy::Patches.refinements.each { |r| using r }

      extend Gemmy::Tests::PatchTests::Error

      def self.thread_test
        # Threads abort on exception
        Thread.new { fail }
        sleep 0.25
        error "thread didn't bubble up error"
      rescue
        puts "  Threads abort on exception".blue
      end

      def self.hash_test
        # Hash#autovivified
        hash = {}.autovivified
        hash[:a][:b] = 0
        error unless hash[:a][:b] == 0
        puts "  Hash#autovivified".blue

        # Hash#bury
        hash = { a: { b: { } } }
        hash.bury(:a, :b, :c, 0)
        error unless hash[:a][:b][:c] == 0
        puts "  Hash#bury".blue

        # Hash#persisted
        db = "test_db.yaml"
        hash = {}.persisted db
        hash.set(:a, :b, 0)
        error unless hash.get(:a, :b) == 0
        error unless hash.get(:a, :b, disk: true) == 0
        error unless YAML.load(File.read db)[:data][:a][:b] == 0
        File.delete(db)
        puts "  Hash#persisted".blue
      end

      def self.array_test
        # Array#any_not?
        false_case = [[]].any_not? &:empty?
        true_case = [[1]].any_not? &:empty?
        error unless true_case && !false_case
        puts "  Array#any_not?".blue
      end

      def self.symbol_test
        # Symbol#with
        result = [[]].map &:concat.with([1])
        error unless result == [[1]]
        puts "  Symbol#with".blue
      end

      def self.method_test
        # Method#bind
        def self.add(a,b)
          a + b
        end
        result = [0].map &method(:add).bind(1)
        error unless result == [1]
        puts "  Method#bind".blue
      end

      def self.global_test
        # m is an alias for method
        def self.sample_method(x)
          x
        end
        result = [0].map &m(:sample_method)
        error unless result == [0]
        puts "  Object#m".blue

        # error_if_blank
        # error an error if an object is blank
        blank = nil
        not_blank = 0
        error_if_blank not_blank
        begin
          error_if_blank blank
          error("this won't be raised")
        rescue RuntimeError => e
          error if e.message == "this won't be raised"
          puts "  Object#error_if_blank".blue
        end
      end

      def self.string_test
        # String#unindent
        result = "  0".unindent
        error unless result == "0"
        puts "  String#unindent".blue
      end

    end

  end

  TestSets << PatchTests

end
