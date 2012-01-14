require 'minesweeper'

class Minesweeper::Field
  include Minesweeper::Logging
  include Enumerable

  def initialize status_grid, mine_count
    @status_grid, @mine_count = status_grid, mine_count
    @rows = status_grid.length
    @cols = status_grid.map(&:length).max
    @size = @rows * @cols
  end

  def each
    @rows.times do |row|
      @cols.times do |col|
        yield row, col, @status_grid[row][col]
      end
    end
  end
end