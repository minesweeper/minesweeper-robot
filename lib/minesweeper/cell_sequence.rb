require 'minesweeper'

class Minesweeper::CellSequence
  attr_reader :cells

  def initialize field, cells
    @field, @cells = field, cells
  end

  def all
    @cells.map {|cell| [cell[0], cell[1]]}
  end

  def first
    f = @cells.first
    [f[0],f[1]]
  end

  def count
    @cells.count
  end

  def unclicked
    Minesweeper::CellSequence.new @field, @cells.select {|cell| cell[2] == 'unclicked'}
  end

  def mined
    Minesweeper::CellSequence.new @field, @cells.select {|cell| cell[2] == 'mine'}
  end
end