# frozen_string_literal: true

# Implement a method #stock_picker that takes in an array of stock prices, one for each hypothetical day.
# It should return a pair of days representing the best day to buy and the best day to sell. Days start at 0.

input = [17, 3, 6, 9, 15, 8, 6, 1, 10]

def stock_picker(stocks)
  profit = 0
  best_buy = 0
  best_sell = 0
  stocks.each_with_index do |value, index|
    i = index + 1
    until i == stocks.length
      if (stocks[i] - value) > profit
        profit = (stocks[i] - value)
        best_buy = value
        best_sell = stocks[i]
      end
      i += 1
    end
  end
  [stocks.index(best_buy), stocks.index(best_sell)]
end

p stock_picker(input)
