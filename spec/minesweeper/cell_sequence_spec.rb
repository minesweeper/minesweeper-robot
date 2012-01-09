$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/cell_sequence'

describe Minesweeper::CellSequence do
  let :sequence do
    Minesweeper::CellSequence.new [
      [0,0,'mine'  ],[0,1,'mines1'],[0,2,'unclicked'],
      [1,0,'mines2'],               [1,2,'unclicked'],
      [2,0,'mine'  ],[2,1,'mines2'],[2,2,'unclicked']
    ]
  end

  it 'should provide a count' do
    sequence.count.should == 8
  end

  it 'should provide a filter on unclicked cells' do
    sequence.unclicked.count.should == 3
  end

  it 'should provide a filter on mined cells' do
    sequence.mined.count.should == 2
  end
end