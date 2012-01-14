module Minesweeper
  MAP = Hash[*%w{. unclicked * marked ! mine % clicked_mine}]
  (0..9).each {|index| MAP[index.to_s] = "mines#{index}"}

  def string_to_status_grid field_string
    field_string.split("\n").map do |row|
      row.split.map {|cell| MAP[cell]}
    end
  end

  def consecutive? *numbers
    (numbers.min..numbers.max).to_a == numbers.sort
  end

  def adjacent? *cells
    return false unless cells.size > 1
    rows = cells.map {|cell| cell[0]}.uniq
    cols = cells.map {|cell| cell[1]}.uniq
    (rows.size == 1 and consecutive? *cols) or
    (cols.size == 1 and consecutive? *rows) or
    (consecutive? *cols and consecutive? *rows and cells.size == 2)
  end

  def with_adjacent_mine_count status
    yield $1.to_i if status =~ /mines(\d)/
  end

  def create_field status_grid_string, mine_count
    Minesweeper::Field.new string_to_status_grid(status_grid_string), mine_count
  end
end