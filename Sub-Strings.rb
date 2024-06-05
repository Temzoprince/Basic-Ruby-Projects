# frozen_string_literal: true

def substrings(string, dictionary)
  i = 0
  words = string.split(' ')
  substrings = Hash.new(0)
  until i == dictionary.length
    words.each do |word|
      # p dictionary[i]
      substrings[dictionary[i]] += 1 if word.downcase.include? dictionary[i]
    end
    i += 1
  end
  substrings
end

def substrings2(string, dictionary)
  words = string.split(' ')
  dictionary.each_with_object(Hash.new(0)) do |substring, list|
    words.each do |word|
      list[substring] += 1 if word.downcase.include? substring
      # p list
    end
  end
end

dictionary = %w[below down go going horn how howdy it i low own part partner sit]

# puts substrings("below", dictionary)
# puts substrings2('below', dictionary)

# puts substrings("Howdy partner, sit down! How's it going?", dictionary)
puts substrings2("Howdy partner, sit down! How's it going?", dictionary)
