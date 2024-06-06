# frozen_string_literal: true

# Implement a method #substrings that takes a word as the first argument and then an array of valid substrings (your dictionary) as the second argument. 
# It should return a hash listing each substring (case insensitive) that was found in the original string and how many times it was found.


def substrings(string, dictionary)
  words = string.split(' ')
  dictionary.each_with_object(Hash.new(0)) do |substring, list|
    words.each do |word|
      list[substring] += 1 if word.downcase.include? substring
    end
  end
end

dictionary = %w[below down go going horn how howdy it i low own part partner sit]

puts substrings("below", dictionary)

puts substrings("Howdy partner, sit down! How's it going?", dictionary)
