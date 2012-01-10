require 'minesweeper/field_analyser'

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
      @game.reset rows: rows, cols: cols, mineCount: mines
      play_game rows, cols, mines
      won += 1 if @game.won?
      lost += 1 if @game.lost?
      puts "won: #{won}, lost: #{lost}"
    end
  end

  def play_game rows, cols, mines
    while true
      return if @game.won? or @game.lost?
      field.obvious_mines.each {|mine| @game.right_click *mine }
      @game.click *next_cell
    end
  end

  def next_cell    
    field.unclicked.first
  end

  private

  def field
    Minesweeper::FieldAnalyser.new @game.field
  end
end