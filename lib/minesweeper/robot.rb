require 'minesweeper'

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
    [[1,1]]
  end

  def play options={}
    rows = options[:rows] || 8
    cols = options[:cols] || 8
    mines = options[:mines] || 4
    won = 0
    lost = 0
    while true
      play_game rows, cols, mines
      won += 1 if @game.won?
      lost += 1 if @game.lost?
      puts "won: #{won}, lost: #{lost}"
    end
  end

  def play_game rows, cols, mines
    @game.reset rows: rows, cols: cols, mineCount: mines
    (0...rows).each do |row|
      (0...cols).each do |col|
        return if @game.won? or @game.lost? 
        @game.click row, col
      end
    end
  end

  private

  def neighbours_of row, col
    2
  end
end