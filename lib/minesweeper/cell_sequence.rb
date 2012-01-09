require 'minesweeper'

class Minesweeper::CellSequence
  def initialize cells
    @cells = cells
  end

  def count
    @cells.count
  end

  def unclicked
    Minesweeper::CellSequence.new @cells.select {|cell| cell[2] == 'unclicked'}
  end
end