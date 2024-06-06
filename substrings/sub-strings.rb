# frozen_string_literal: true

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
