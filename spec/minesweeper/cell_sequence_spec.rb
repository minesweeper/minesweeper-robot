$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field_analyser'

describe Minesweeper::CellSequence do
  let :sequence do
    field = Minesweeper.string_to_field <<-EOF
    * 1 . .
    2 . . .
    * 2 . .
    EOF
    sequence = Minesweeper::FieldAnalyser.new(field).neighbours_of 1, 1
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