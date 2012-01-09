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
end