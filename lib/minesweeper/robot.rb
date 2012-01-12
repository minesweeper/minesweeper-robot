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

  def duration
    start_time = Time.now.to_i
    yield
    Time.now.to_i - start_time
  end

  def play options={}
    beginner =     {rows: 9,  cols: 9,  mineCount: 10}
    intermediate = {rows: 16, cols: 16, mineCount: 40}
    expert =       {rows: 16, cols: 30, mineCount: 99}
    @options = expert.merge options
    rows,cols,mineCount = *%w{rows cols mineCount}.map {|key| @options[key.to_sym] }
    won = 0
    games = 1
    fastest_time = nil
    while true
      puts "Game #{games}"
      @game.reset @options
      time = duration { play_game rows, cols, mineCount }
      if @game.won?
        won += 1
        fastest_time ||= time
        fastest_time = time if time < fastest_time
        puts "Won in #{time} seconds (fastest time is #{fastest_time} seconds)"
      end
      puts "Summary: Won #{won}/#{games}"
    end
  end

  def play_game rows, cols, mines
    turn = 0
    while true
      return if @game.finished?
      puts "  Turn #{turn}"
      field.obvious_mines.tap {|it| puts "    Marking obvious mines #{it.inspect}"}.each do |mine|
        @game.right_click *mine
      end
      @game.click *next_cell
      turn += 1
    end
  end

  def next_cell
    safe_cells = field.safe_cells_to_click
    unless safe_cells.empty?
      puts "    Clicking safe cell #{safe_cells.first.inspect}"
      return safe_cells.first
    end
    field.least_likely_to_be_mined
  end

  private

  def field
    Minesweeper::FieldAnalyser.new @game.field, @options[:mineCount]
  end
end