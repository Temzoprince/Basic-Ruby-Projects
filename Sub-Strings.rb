def substrings(string, dictionary)
  i = 0
  substrings = Hash.new(0)
  until i == dictionary.length
    p dictionary[i]
    substrings[dictionary[i]] += 1 if string.include? dictionary[i]
    i += 1
  end
  substrings
end

def substrings2(string, dictionary)
  dictionary.reduce(Hash.new(0)) do |list, substring|
    list[substring] += 1 if string.include? substring
    # p list
    list
  end
end

dictionary = ["below","down","go","going","horn","how","howdy","it","i","low","own","part","partner","sit"]

# puts substrings("below", dictionary)
puts substrings2("below", dictionary)

# substrings2("Howdy partner, sit down! How's it going?", dictionary)

