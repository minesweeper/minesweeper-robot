require 'minesweeper/cell_sequence'

class Minesweeper::Field
  include Enumerable

  attr_reader :row_count, :col_count, :mine_count

  def initialize status_grid, mine_count
    @status_grid, @mine_count = status_grid, mine_count
    @row_count = status_grid.length
    @col_count = status_grid.map(&:length).max
  end

  def each
    @row_count.times do |row_index|
      @col_count.times do |col_index|
        yield row_index, col_index, @status_grid[row_index][col_index]
      end
    end
  end

  def count_for_status status
    count {|r,c,s| s == status }
  end

  def remaining_mine_count
    mine_count - count_for_status('marked')
  end

  def status_at row, col
    @status_grid[row][col]
  end

  def all
    Minesweeper::CellSequence.new self, to_a
  end

  def each_neighbour_of row,col
    (row-1..row+1).map do |r|
      (col-1..col+1).map do |c|
        yield r, c, @status_grid[r][c] unless (row == r and col == c) or r < 0 or c < 0 or r >= @row_count or c >= @col_count
      end
    end
  end

  def neighbours_of row, col
    cells = []
    each_neighbour_of(row,col) {|r,c,s| cells << [r,c,s] }
    Minesweeper::CellSequence.new self, cells
  end
end