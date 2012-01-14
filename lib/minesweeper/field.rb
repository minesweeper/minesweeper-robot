require 'minesweeper'

class Minesweeper::Field
  include Minesweeper::Logging
  include Enumerable

  attr_reader :row_count, :col_count

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
end