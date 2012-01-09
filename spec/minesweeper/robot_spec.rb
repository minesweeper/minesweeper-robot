$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/robot'

describe Minesweeper::Robot do
  it 'should detect obvious mines' do
    game = stub 'game'
    player = Minesweeper::Robot.new game
    game.should_receive(:field).and_return Minesweeper::Game.string_to_field <<-EOF
    1 1 .
    1 . .
    EOF
    player.obvious_mines.should == [[1, 1]]
  end
end