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
        neighbours << [r,c] unless (row == r and col == c) or r < 0 or c < 0
      end
    end
    neighbours
  end
end