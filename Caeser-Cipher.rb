# require 'pry-byebug'

def caesar_cipher(string, key)
    # # binding.pry

    array_string = string.split("")
    p array_string
    encrypt_array = array_string.map do |letter|
        encrypt_letter = letter.ord
        if encrypt_letter >= 65 && encrypt_letter <= 90
            encrypt_letter += 5
            if encrypt_letter > 90
                encrypt_letter -= 26
            end
        end
        if encrypt_letter >= 97 && encrypt_letter <= 122
            encrypt_letter += 5
            if encrypt_letter > 122
                encrypt_letter -= 26
            end
        end
        letter = encrypt_letter.chr
    end
    p encrypt_array
    encrypt_array.join("")

end

puts caesar_cipher("What a string!", 5)