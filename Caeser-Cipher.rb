# require 'pry-byebug'

alphabet = ('a'..'z').to_a
# puts alphabet

def caesar_cipher(string, key)
    alphabet = ('a'..'z').to_a
    # puts alphabet

    # binding.pry


    array_string = string.split("")
    p array_string
    encrypt_array = array_string.map do |letter|
        if letter == ' ' || letter == '!'
            next
        end
        upcase = true if letter.upcase == letter
        shift_value = alphabet.index(letter.downcase) + key
        p shift_value
        if shift_value > 25
            shift_value = shift_value - 26
        end
        if letter == ' ' || letter == '!'
            letter
        elsif upcase
            letter = alphabet[shift_value].upcase
        else
            letter = alphabet[shift_value]
        end
    end
    p encrypt_array
    encrypt_array.join("")
end

puts caesar_cipher("What a string!", 5)

puts alphabet.find_index('z')