def common_digits_count(first_number, second_number)
  first_number.abs.to_s.chars.select do |n|
    second_number.abs.to_s.chars.include? n
  end.uniq.count
end
