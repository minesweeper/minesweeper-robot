module Minesweeper; end

class Minesweeper::Robot
  def initialize game
    @game = game
  end

  def obvious_mines
    obvious_mines = []
    @game.field.each_with_index do |row, row_num|
      row.each_with_index do |cell, col_num|
        obvious_mines << [row_num, col_num] if cell == 'mines2' and neighbours(row_num, col_num) == 2
      end
    end
    obvious_mines
  end

  def play
  end

  private

  def neighbours_of row, col
    2
  end
end