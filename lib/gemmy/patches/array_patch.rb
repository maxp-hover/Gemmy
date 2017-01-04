# Array patches
#
module Gemmy::Patches::ArrayPatch

  module ClassMethods

    module Wrap
      using CF::Array[:wrap]
      def self.autotest
        Array.wrap(nil).eql?([]) &&\
        Array.wrap([]).eql?([]) &&\
        Array.wrap(1).eql?([1])
      end
    end

    module Zip
      # facets
      def zip(*arrays)
        return [] if arrays.empty?
        return arrays[0].zip(*arrays[1..-1])
      end
      def self.autotest
        Array.zip([1], [2]) == [[1,2]]
      end
    end

  end

  module InstanceMethods

    module Reject
      # make it an alias for reject(&:blank?) if no block given
      def reject(&blk)
        blk ? super : reject(&:blank?)
      end
    end

    module Cut
      # another alias for compact
      def cut
        compact
      end
    end

    module RunCommands
      # Part of the Nlp API
      # Example:
      #    include Gemmy::Components::Nlp
      #    parse_sentence("A sentence").run_commands
      #
      # Under the hood, parse_sentence is creating procs in the db
      # These are evaluated here
      #
      def run_commands
        _eval_noun = Gemmy.patch("string/i/eval_noun")
                          .method(:_eval_noun)
        return self.flat_map do |cmds|
          cmds&.map do |cmd|
            eval(VerbLexicon.get cmd[:verb].to_sym).call(*(
              cmd[:nouns]&.map do |noun|
                _eval_noun.call(noun, self)
              end
            ).to_a.compact)
          end
        end.compact
      end
    end

    module Exclude
      # facets
      # the opposite of include
      def exclude?(x)
        ! include? x
      end
      def self.autotest
        [1].exclude?(2) && ![2].exclude?(2)
      end
    end

    module KeyBy
      # facets
      def key_by
        return to_enum(:key_by) unless block_given?
        h = Hash.new { |h,k| h[k] = [] }
        each do |v|
          h[yield(v)] << v
        end
        return h
      end
      def self.autotest
        [1,2,3].key_by { |v| v % 2 } == { 1 => [1, 3], 0 => [2] }
      end
    end

    module After
      # facets
      def after(value)
        return nil unless include? value
        self[(index(value).to_i + 1) % length]
      end
      def self.autotest
        [1,2].after(1).eql?(2)
      end
    end

    module Before
      # facets
      def before(value)
        return nil unless include? value
        self[(index(value).to_i - 1) % length]
      end
      def self.autotest
        [1,2].before(2) == 1
      end
    end

    module Duplicates
      # facets
      def duplicates(min=2)
        h = Hash.new( 0 )
        each {|i|
          h[i] += 1
        }
        h.delete_if{|_,v| v < min}.keys
      end
      def self.autotest
        [1,1,2,2,3].duplicates == [1,2]
      end
    end

    module RejectValues
      # facets
      def reject_values(*values)
        reject { |x| values.include?(x) }
      end
    end

    module Recurse
      # facets
      def recurse(*types, &block)
        types = [self.class] if types.empty?
        a = inject([]) do |array, value|
          case value
          when *types
            array << value.recurse(*types, &block)
          else
            array << value
          end
          array
        end
        yield a
      end
    end

    module Probability
      # facets
      def probability
        probs = Hash.new(0.0)
        size = 0.0
        each do |e|
          probs[e] += 1.0
          size += 1.0
        end
        probs.keys.each{ |e| probs[e] /= size }
        probs
      end
    end

    module NotEmpty
      # facets
      def not_empty?
        !empty?
      end
    end

    module Median
      # facets
      def median(offset=0)
        return nil if self.size == 0

        tmp = self.sort
        mid = (tmp.size / 2).to_i + offset

        tmp[mid]
      end
    end

    module Mode
      # facets
      def mode
        max = 0
        c = Hash.new 0
        each {|x| cc = c[x] += 1; max = cc if cc > max}
        c.select {|k,v| v == max}.map {|k,v| k}
      end
    end

    module NonUniq

      # facets
      def nonuniq
        h1 = {}
        h2 = {}
        each {|i|
          h2[i] = true if h1[i]
          h1[i] = true
        }
        h2.keys
      end
    end

    module Arrange
      # facets
      # creates ranges from array
      def arrange
        array = uniq.sort_by { |e| Range === e ? e.first : e }
        array.inject([]) do |c, value|
          unless c.empty?
            last = c.last
            last_value    = (Range === last  ? last.last   : last)
            current_value = (Range === value ? value.first : value)
            if (last_value.succ <=> current_value) == -1
              c << value
            else
              first  = (Range === last ? last.first : last)
              second = [Range === last ? last.last : last, Range === value ? value.last : value].max
              c[-1] = [first..second]
              c.flatten!
            end
          else
            c << value
          end
        end
      end
      alias rangify arrange
    end



    module AnyNot
      # checks if any of the results of an array do not respond truthily
      # to a block
      #
      # For example, to check if any items of an array are truthy:
      #   [false, nil, ''].any_not? &:blank?
      #   => false
      #
      def any_not?(&blk)
        any? { |item| ! blk.call(item) }
      end
    end

  end

end
