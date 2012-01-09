$: << File.dirname(__FILE__)+'/../lib'

require 'minesweeper/robot'
require 'minesweeper/game'

describe Minesweeper::Robot do
  attr_reader :game
 
  before :all do
    @game = Minesweeper::Game.new
  end

  after :all do
    game.destroy
  end

  def with_game options
    game.reset options
  end

  it 'should get initial field containing only unknown status' do
    with_game rows: 2, cols: 2
    game.field.should == [
      [:unclicked, :unclicked],
      [:unclicked, :unclicked]
    ]
  end

  it 'should win the game if the mine is clicked' do
    with_game rows: 1, cols: 2, mineCount: 1
    game.click 0, 0
    game.field.should == [
      [:mines1, :unclicked]
    ]
    game.should be_won
  end
end