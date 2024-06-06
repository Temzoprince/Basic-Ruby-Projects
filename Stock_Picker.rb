input = [17,3,6,9,15,8,6,1,10]

def stock_picker(stocks)
    profit = 0;
    best_buy = 0;
    best_sell = 0;
    stocks.each_with_index do |value, index|
        i = index + 1
        until i == stocks.length
            # p stocks[i]
            if (stocks[i] - value) > profit
                profit = (stocks[i] - value)
                best_buy = value
                best_sell = stocks[i]
            end
            i += 1
        end
    end
    [best_buy, best_sell]
end

puts stock_picker(input)