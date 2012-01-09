$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/robot'

describe Minesweeper::Robot do
  it 'should ' do
    game = stub 'game'
    player = Minesweeper::Player.new game
    game.should_receive(:field).and_return 
    player.obvious_mines.should == [[]]
  end
end