require 'minesweeper/logging'
require 'minesweeper/field'
require 'minesweeper/field_analyser'

class Minesweeper::Robot
  include Minesweeper::Logging

  def initialize game
    @game = game
    @mine_count = @game.mine_count
    @row_count = @game.row_count
    @col_count = @game.col_count
  end

  def duration
    start_time = Time.now.to_i
    yield
    Time.now.to_i - start_time
  end

  def play max_games
    won = 0
    games = 1
    fastest_time = nil
    while true
      puts "Game #{games}"
      @game.reset
      time = duration { play_game }
      if @game.won?
        won += 1
        fastest_time ||= time
        fastest_time = time if time < fastest_time
        puts "Won in #{time} seconds (fastest time is #{fastest_time} seconds)"
      end
      puts "Summary: Won #{won}/#{games}"
      break if games >= max_games
      games += 1
    end
    @game.destroy
  end

  def play_game
    turn = 1
    while true
      return if @game.finished?
      info "  Turn #{turn}"
      analyser.obvious_mines.tap {|it| info "    Marking obvious mines #{it.inspect}"}.each do |mine|
        @game.right_click *mine
      end
      chosen_cells.each do |cell|
        info "    Clicking #{cell.inspect}"
        @game.click *cell
      end
      turn += 1
    end
  end

  def chosen_cells
    safe_cells = analyser.safe_cells_to_click
    safe_cells.empty? ? [analyser.least_likely_to_be_mined] : safe_cells
  end

  def analyser
    Minesweeper::FieldAnalyser.new Minesweeper::Field.new @game.status_grid, @mine_count
  end
end