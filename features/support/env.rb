$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/game'
require 'minesweeper/robot'
require 'rspec'

module Minesweeper
  @game = Minesweeper::Game.new :default, :blank

  def self.game
    @game
  end
end

at_exit do
  Minesweeper.game.destroy
end

RSpec.configure do |config|
  config.mock_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
end

World Minesweeper
