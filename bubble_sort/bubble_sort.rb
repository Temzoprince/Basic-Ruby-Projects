input = [4,3,78,2,0,2]

def bubble_sort(list)
  i = 1
  k = 0
  (list.length - 1).times do
    while i < list.length - k
      if list[i] < list[i - 1]
        temp = list[i - 1]
        list[i - 1] = list[i]
        list[i] = temp
      end
      i += 1
    end
    i = 1
    k += 1
  end
  list
end

p bubble_sort(input)