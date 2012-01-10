require 'minesweeper/cell_sequence'

class Minesweeper::FieldAnalyser
  include Enumerable

  attr_reader :rows, :cols

  def initialize field
    @field = field
    @rows = field.length
    @cols = field.map(&:length).max
  end

  def marked_mines
    count {|r,c,status| status == 'marked' }
  end

  def each
    @rows.times do |row|
      @cols.times do |col|
        yield row, col, @field[row][col]
      end
    end
  end

  def all
    cells = []
    (0...@rows).map do |r|
      (0...@cols).map do |c|
        cells << [r,c,@field[r][c]]
      end
    end
    Minesweeper::CellSequence.new self, cells
  end

  def neighbours_of row, col
    rl,ru=row-1,row+1
    cl,cu=col-1,col+1
    neighbours = []
    (rl..ru).map do |r|
      (cl..cu).map do |c|
        neighbours << [r,c,@field[r][c]] unless (row == r and col == c) or r < 0 or c < 0 or r >= @rows or c >= @cols
      end
    end
    Minesweeper::CellSequence.new self, neighbours
  end

  def safe_cells_to_click
    cells = []
    each do |row, col, status|
      if status =~ /mines(\d)/
        mine_count = $1.to_i
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
      if status =~ /mines(\d)/
        mine_count = $1.to_i
        marked_count = neighbours_of(row,col).marked.count
        unclicked_neighbours = neighbours_of(row,col).unclicked
        cells += unclicked_neighbours.all if mine_count == (marked_count + unclicked_neighbours.count)
      end
    end
    cells.uniq
  end
end