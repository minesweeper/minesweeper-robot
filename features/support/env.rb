$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/game'

module Minesweeper
  @game = Minesweeper::Game.new :default, :blank

  def self.game
    @game
  end
end

at_exit do
  Minesweeper.game.destroy
end

World Minesweeper