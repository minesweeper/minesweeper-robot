$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/robot'

describe Minesweeper::Robot do
  let(:game) { stub 'game' }
  let(:robot) { Minesweeper::Robot.new game } 

  def field field_string
    game.should_receive(:field).and_return Minesweeper.string_to_field field_string
  end

  it 'should detect obvious mines with 1 adjacent' do
    field <<-EOF
    1 1 .
    1 . .
    EOF
    robot.obvious_mines.should == [[1, 1]]
  end

  # it 'should detect obvious mines with 2 adjacent' do
  #   field <<-EOF
  #   2 1 .
  #   . . .
  #   EOF
  #   robot.obvious_mines.should == [[1,0],[1, 1]]
  # end
end
