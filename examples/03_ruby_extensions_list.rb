# All these examples assume Gemmy is loaded globally
Gemmy.load_globally

# ==========================================================================
# COMPONENTS
# ==========================================================================

# -------------
# Dynamic Steps (poor man's NLP)
# -------------

# define a step
define_step(/is this a palindrome\? (.+)/) { |str| str.reverse == str }

# call a step
step "is this a palindrome? tacocat" # => true


# ==========================================================================
# PATCHES
# ==========================================================================

# -------------
# Array
# -------------

# any_not?
['', {}, nil].any_not? &:blank?

# -------------
# Object
# -------------

# turn on verbose mode
verbose_mode

# quick-n-easy error
error("rescue me") rescue nil

# prompt
# uses gets under the hood, so make sure to clear
# ARGV before using it unless it's your intention
# for gets to read from ARGV.
# In this case I want to pass it a val from ARGV
File.open("my_name", 'w') { |f| f.write("my_name") }
ARGV.unshift "my_name"
puts _prompt("what's your name") # => max
ARGV.clear

# shift from ARGV and raise an error if its nil
ARGV.unshift "my_name"
get_arg_or_error("error message")
ARGV.clear
`rm my_name`

# write a string to a file
write(file: "/tmp/file.txt", text: "hello file")

# raise an error if an object is blank
error_if_blank(nil, "error message") rescue "ok"

# m is an alias for method
arr = []
[1].each &arr.m(:push) # now arr == [1]

# The best method
nothing

# -------------
# String
# -------------

# unindent is an alias for active support's
# strip_heredoc
<<-TXT.unindent
  asd
    ok
TXT
# => asd\n  ok"

# -------------
# Symbol
# -------------

[1,2,3].map &:*.with(2)
# => [2,4,6]

# -------------
# Method
# -------------

# Bind arguments to method, i.e. curry
def join_all(*strings); strings.join ;end
joined =  %w{1 2 3}.map(&method(:join_all).bind("and "))
# => "1 and 2 and 3"

# -------------
# Thread
# -------------

# There isn't actually any patched method that
# can be called, but when the Thread patch
# is loaded, Threads will now abort on exception
