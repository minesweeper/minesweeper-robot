$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/game'

module Minesweeper
  @game = Minesweeper::Game.new

  def self.game
    @game
  end
end

at_exit do
  Minesweeper.game.destroy
end