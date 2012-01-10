require 'minesweeper'

class Minesweeper::FieldAnalyser
  attr_reader :rows, :cols

  def initialize field
    @field = field
    @rows = field.length
    @cols = field.map(&:length).max
  end

  def neighbours_of row, col
    rl,ru=row-1,row+1
    cl,cu=col-1,col+1
    neighbours = []
    (rl..ru).map do |r|
      (cl..cu).map do |c|
        neighbours << [r,c] unless (row == r and col == c) or r < 0 or c < 0 or r >= @rows or c >= @cols
      end
    end
    neighbours
  end

  def neighbour_statuses_of row, col
    neighbours_of(row,col).map do |neighbour|
      r,c = *neighbour
      [r,c,@field[r][c]]
    end
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

  def neighbours_of_status row, col, status
    neighbour_statuses_of(row, col).select{|e| e[2] == status }.collect {|e|[e[0],e[1]]}
  end
end