$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/robot'

describe Minesweeper::Robot do
  let(:game) { stub 'game' }
  let(:robot) { Minesweeper::Robot.new game } 

  def field field_string
    game.should_receive(:field).and_return Minesweeper::Game.string_to_field field_string
  end

  it 'should detect obvious mines' do
    field <<-EOF
    1 1 .
    1 . .
    EOF
    robot.obvious_mines.should == [[1, 1]]
  end
end