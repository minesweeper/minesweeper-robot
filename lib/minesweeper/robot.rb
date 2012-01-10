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
    beginner =     {rows: 9,  cols: 9,  mineCount: 10}
    intermediate = {rows: 16, cols: 16, mineCount: 40}
    expert =       {rows: 16, cols: 30, mineCount: 99}
    options = intermediate.merge options
    rows,cols,mines = *%w{rows cols mineCount}.map {|key| options[key.to_sym] }
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
    turn = 0
    while true
      return if @game.won? or @game.lost?
      puts "Turn #{turn}"
      obvious_mines = field.obvious_mines
      puts "Marking obvious mines #{obvious_mines.inspect}"
      obvious_mines.each { |mine| @game.right_click *mine }
      @game.click *next_cell
      turn += 1
    end
  end

  def next_cell
    safe_cells = field.safe_cells_to_click
    unless safe_cells.empty?
      puts "Clicking safe cell #{safe_cells.first.inspect}"
      return safe_cells.first
    end
    all = field.all.unclicked
    puts "Clicking next cell #{all.first.inspect} (no safe cells)"
    all.first
  end

  private

  def field
    Minesweeper::FieldAnalyser.new @game.field
  end
end