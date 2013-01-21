def agingify hash
  move = hash.select { |k, v| v < 0 }.values.inject(0) { |sum, t| sum += t }
  hash.keys.each { |k| hash[k] = 0 if hash[k] < 0 }
  hash.keys.reverse.each do |k| 
    if move + hash[k] <= 0
      move += hash[k]
      hash[k] = 0
    else
      hash[k] = hash[k] + move
      move = 0
    end
  end
end

list = {
  0 => 100,
  1 => 200,
  2 => 500,
  3 => -900,
  4 => 100,
  5 => -500
}

agingify list
