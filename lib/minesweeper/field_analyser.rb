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

  def marked_mines
    count {|r,c,status| status == 'marked' }
  end

  def probability_of_mine_at row, col
    mines.to_f/@size.to_f
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

  def neighbours_of row, col
    neighbours = []
    (row-1..row+1).map do |r|
      (col-1..col+1).map do |c|
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