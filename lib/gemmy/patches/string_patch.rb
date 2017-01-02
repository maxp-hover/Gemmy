# String patches
#
module Gemmy::Patches::StringPatch

  module ClassMethods
  end

  module InstanceMethods

    module Unchomp
      def unchomp
        self.ends_with?("\n") ? self : "#{self}\n"
      end
    end

    module SyllableCount
      def syllable_count
        Odyssey.flesch_kincaid_re(self, true)["syllable_count"]
      end
    end

    module NlpSanitize
      # Removes non-alphanumerics and newline
      # Converts numbers to english
      def nlp_sanitize
        Gemmy.patch("string/i/alpha")
          ._alpha(self)
          .downcase
          .strip
          .numbers_to_english
          .chomp
      end
    end

    module NumbersToEnglish
      # Converts a string's numbers to english words
      def numbers_to_english
        Gemmy.patch("string/i/numbers_to_english").numbers_to_english(self)
      end
      def self.numbers_to_english(string)
        string.gsub(/(\d+)/) { |num| num.humanize }
      end
    end

    module Alpha
      def self._alpha(string, bang: false, strip_whitespace: false)
        fn = bang ? :gsub! : :gsub
        regex = /[^a-zA-Z0-9#{'\s' unless strip_whitespace}]/
        string.send fn, regex, ''
      end
      def alpha!(opts={})
        Gemmy.patch("string/i/alpha")._alpha(
          self,
          opts.merge(bang: true)
        )
      end
      # Gsub non-alphabetical characters
      def alpha(opts={})
        Gemmy.patch("string/i/alpha")._alpha(
          self,
          opts
        )
      end
    end

    module TempfilePath
      # Creates a tempfile containing a string and returns its path
      def tempfile_path
        Tempfile.new.tap { |t| t.write(self); t.close }.path
      end
    end

    module EvalNoun
      def eval_noun(commands=[])
        Gemmy.patches("string/i/eval_noun")._eval_noun self, commands
      end
      def self._eval_noun(noun, commands=[])
        eval(NounLexicon.get(noun.to_sym)).call(commands)
      end
    end

    module Words
      # facets
      def words
        self.split(/\s+/)
      end
    end

    module Rotate
      # facets
      # 'abcdefgh'.rotate(2)  #=> 'cdefghab'
      # 'abcdefgh'.rotate(-2) #=> 'ghabcdef'
      def rotate(count=1)
        count+=self.length if count<0
        self.slice(count,self.length-count)+self.slice(0,count)
      end
    end

    module Range
      # facets
      # Gets the start/end indexes of a match to <pattern>
      # only considers first match
      def range(pattern, offset=0)
        unless Regexp === pattern
          pattern = Regexp.new(Regexp.escape(pattern.to_s))
        end
        string = self[offset..-1]
        if md = pattern.match(string)
          return (md.begin(0)+offset)..(md.end(0)+offset-1)
        end
        nil
      end
    end

    module RangeAll
      # facets
      # like #range patch but returns start/end indexes of all matches
      def range_all(pattern, reuse=false)
        r = []; i = 0
        while i < self.length
          rng = range(pattern, i)
          if rng
            r << rng
            i += reuse ? 1 : rng.end + 1
          else
            break
          end
        end
        r.uniq
      end
    end

    module IsNumber
      # facets
      def is_number?
        !!self.match(/\A[+-]?\d+?(_?\d+?)*?(\.\d+(_?\d+?)*?)?\Z/)
      end
    end

    module EachMatch
      # facets
      # iterator over matches from regex
      def each_match(re) #:yield:
        if block_given?
          scan(re) { yield($~) }
        else
          m = []
          scan(re) { m << $~ }
          m
        end
      end
    end

    module LineWrap
      # facets
      # wrap lines at width
      def line_wrap(width, tabs=4)
        s = gsub(/\t/,' ' * tabs) # tabs default to 4 spaces
        s = s.gsub(/\n/,' ')
        r = s.scan( /.{1,#{width}}/ )
        r.join("\n") << "\n"
      end
    end

    module Lchomp
      # facets
      def lchomp(match)
        if index(match) == 0
          self[match.size..-1]
        else
          self.dup
        end
      end
    end

    module IndexAll
      # facets
      # standard String#index only shows the first match
      def index_all(s, reuse=false)
        s = Regexp.new(Regexp.escape(s)) unless Regexp===s
        ia = []; i = 0
        while (i = index(s,i))
          ia << i
          i += (reuse ? 1 : $~[0].size)
        end
        ia
      end
    end

    module Indent
      # facets
      def indent(n, c=' ')
        if n >= 0
          gsub(/^/, c * n)
        else
          gsub(/^#{Regexp.escape(c)}{0,#{-n}}/, "")
        end
      end
    end

    module ExpandTabs
      # turns tabs to spaces
      def expand_tabs(n=8)
        n = n.to_int
        raise ArgumentError, "n must be >= 0" if n < 0
        return gsub(/\t/, "") if n == 0
        return gsub(/\t/, " ") if n == 1
        str = self.dup
        while
          str.gsub!(/^([^\t\n]*)(\t+)/) { |f|
            val = ( n * $2.size - ($1.size % n) )
            $1 << (' ' * val)
          }
        end
        str
      end
    end

    module Exclude
      # facets
      def exclude?(str)
        !include?(str)
      end
    end

    module CompressLines
      # facets
      # replace newlines or N spaces with one space
      def compress_lines(spaced = true)
        split($/).map{ |line| line.strip }.join(spaced ? ' ' : '')
      end
    end

    module AlignCenter
      # facets
      def align_center(n, sep="\n", c=' ')
        return center(n.to_i,c.to_s) if sep==nil
        q = split(sep.to_s).collect { |line|
          line.center(n.to_i,c.to_s)
        }
        q.join(sep.to_s)
      end
    end

    module AlignLeft
      # facets
      def align_left(n, sep="\n", c=' ')
        return ljust(n.to_i,c.to_s) if sep==nil
        q = split(sep.to_s).map do |line|
          line.strip.ljust(n.to_i,c.to_s)
        end
        q.join(sep.to_s)
      end
    end

    module AsciiOnly
      # facets
      # remove non ascii characters
      def ascii_only(alt='')
        encoding_options = {
          :invalid                     => :replace,  # Replace invalid byte sequences
          :undef                       => :replace,  # Replace anything not defined in ASCII
          :replace                     => alt,       # Use a blank for those replacements
          :UNIVERSAL_NEWLINE_DECORATOR => true       # Always break lines with \n
        }
        self.encode(Encoding.find('ASCII'), encoding_options)
      end
    end

    module AlignRight
      # facets
      def align_right(n, sep="\n", c=' ')
        return rjust(n.to_i,c.to_s) if sep==nil
        q = split(sep.to_s).map do |line|
          line.rjust(n.to_i,c.to_s)
        end
        q.join(sep.to_s)
      end
    end

    module Subtract
      # facets
      # removes all instances of a pattern from a string 
      def -(pattern)
        gsub(pattern, '')
      end
    end

    module Random
      # facets
      # a random string of length n with a given character set
      def self.random(len=32, character_set = ["A".."Z", "a".."z", "0".."9"])
        characters = character_set.map { |i| i.to_a }.flatten
        characters_len = characters.length
        (0...len).map{ characters[rand(characters_len)] }.join
      end
    end

    # reference 'strip_heredoc' (provided by active support) by 'unindent'
    #
    # this takes an indented heredoc and treats it as if the first line is not
    # indented.
    #
    # Instead of using alias, a method is defined here to enable modular
    # patches
    #
    module Unindent
      def unindent
        strip_heredoc
      end
    end

  end

end
