require 'minesweeper'

class Minesweeper::CellSequence
  def initialize cells
    @cells = cells
  end

  def count
    @cells.count
  end
end