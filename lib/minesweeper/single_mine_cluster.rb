require 'minesweeper'
require 'set'

class Minesweeper::MineCluster
  attr_reader :count, :cells

  def initialize count, cells
    @cells, @count = cells, count
    @cell_set = Set.new @cells
  end

  def subset? set
    @cell_set.subset? set
  end
end