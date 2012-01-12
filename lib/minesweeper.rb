module Minesweeper
  MAP = Hash[*%w{. unclicked * marked ! mine}]
  (0..9).each {|index| MAP[index.to_s] = "mines#{index}"}

  def self.string_to_field field_string
    field_string.split("\n").map do |row|
      row.split.map {|cell| MAP[cell]}
    end
  end

  def self.consecutive? *numbers
    (numbers.min..numbers.max).to_a == numbers.sort
  end

  def self.adjacent? *cells
    return false unless cells.size > 1
    rows = cells.map {|cell| cell[0]}.uniq
    cols = cells.map {|cell| cell[1]}.uniq
    (rows.size == 1 and consecutive? *cols) or (cols.size == 1 and consecutive? *rows)
  end
end