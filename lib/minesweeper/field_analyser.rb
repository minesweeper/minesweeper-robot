require 'minesweeper/cell_sequence'

class Minesweeper::FieldAnalyser
  include Enumerable

  attr_reader :rows, :cols, :mines

  def initialize field,mines=1
    @mines = mines
    @field = field
    @rows = field.length
    @cols = field.map(&:length).max
    @size = rows * cols
  end

  def count_for_status status
    count {|r,c,s| s == status }
  end

  def remaining_mine_count
    mines - count_for_status('marked')
  end

  def probability_of_mine_at row, col
    current = remaining_mine_count.to_f/count_for_status('unclicked')
    each_neighbour_of row, col do |r,c,s|
      with_adjacent_mine_count s do |count|
        chance = count.to_f/neighbours_of(r,c).unclicked.count
        current = chance if chance > current
      end
    end
    current
  end

  def with_adjacent_mine_count status
    yield $1.to_i if status =~ /mines(\d)/
  end

  def each
    @rows.times do |row|
      @cols.times do |col|
        yield row, col, @field[row][col]
      end
    end
  end

  def all
    Minesweeper::CellSequence.new self, to_a
  end

  def each_neighbour_of row,col
    (row-1..row+1).map do |r|
      (col-1..col+1).map do |c|
        yield r, c, @field[r][c] unless (row == r and col == c) or r < 0 or c < 0 or r >= @rows or c >= @cols
      end
    end
  end

  def neighbours_of row, col
    cells = []
    each_neighbour_of(row,col) {|r,c,s| cells << [r,c,s] }
    Minesweeper::CellSequence.new self, cells
  end

  def safe_cells_to_click
    cells = []
    each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        marked_count = neighbours_of(row,col).marked.count
        unclicked_neighbours = neighbours_of(row,col).unclicked
        cells += unclicked_neighbours.all if marked_count == mine_count
      end
    end
    cells.uniq
  end

  def obvious_mines
    cells = []
    each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        marked_count = neighbours_of(row,col).marked.count
        unclicked_neighbours = neighbours_of(row,col).unclicked
        cells += unclicked_neighbours.all if mine_count == (marked_count + unclicked_neighbours.count)
      end
    end
    cells.uniq
  end
end