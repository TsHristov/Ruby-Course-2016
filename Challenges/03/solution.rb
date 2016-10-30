def fibonacci_like?(arr)
  arr.each_cons(3) { |sub_arr| return false if sub_arr.last != sub_arr.take(2).reduce(:+) }
  true
end
