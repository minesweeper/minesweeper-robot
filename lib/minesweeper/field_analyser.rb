require 'minesweeper/cell_sequence'

class Minesweeper::FieldAnalyser
  include Enumerable

  attr_reader :rows, :cols

  def initialize field
    @field = field
    @rows = field.length
    @cols = field.map(&:length).max
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
    safe_cells = []
    @rows.times do |row|
      @cols.times do |col|
        1.upto 8 do |number_of_mines|
          if @field[row][col] == "mines#{number_of_mines}" and neighbours_of_status(row, col, 'mine').count == number_of_mines
            safe_cells += neighbours_of_status(row, col, 'unclicked')
          end
        end
      end
    end
    safe_cells.uniq
  end

  def obvious_mines
    cells = []
    each do |row, col, status|
      if status =~ /mines(\d)/
        mine_count = $1.to_i
        current_mine_count = neighbours_of(row,col).mined.count
        unclicked_neighbours = neighbours_of(row,col).unclicked
        cells += unclicked_neighbours.all if mine_count == (current_mine_count + unclicked_neighbours.count)
      end
    end
    cells.uniq
  end

  def neighbours_of_status row, col, status
    neighbours_of(row, col).cells.select{|e| e[2] == status }.collect {|e|[e[0],e[1]]}
  end
end