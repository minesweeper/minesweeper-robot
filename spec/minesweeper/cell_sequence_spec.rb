$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field'

describe Minesweeper::CellSequence do
  include Minesweeper

  let :sequence do
    create_field(<<-EOF, 1).neighbours_of 1, 1
    * 1 . .
    2 . . .
    * 2 . .
    EOF
  end

  it 'should provide a count' do
    sequence.count.should == 8
  end

  it 'should provide a filter on unclicked cells' do
    sequence.unclicked.count.should == 3
  end

  it 'should provide a filter on marked cells' do
    sequence.marked.count.should == 2
  end
end