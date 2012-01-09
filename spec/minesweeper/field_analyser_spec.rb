$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field_analyser'

describe Minesweeper::FieldAnalyser do
  def field field_string
    @analyser = Minesweeper::FieldAnalyser.new Minesweeper.string_to_field field_string
  end

  it 'should determine row length' do
    field <<-EOF
    . .
    . .
    . .
    EOF
    @analyser.rows.should == 3
  end

  it 'should determine col count of game' do
    field <<-EOF
    . .
    . .
    . .
    EOF
    @analyser.cols.should == 2
  end

  it 'should get neighbour coordinates for a middle cell' do
    field <<-EOF
    . . .
    . . .
    . . .
    EOF
    @analyser.neighbours_of(1,1).should == [
      [0,0],[0,1],[0,2],
      [1,0],      [1,2],
      [2,0],[2,1],[2,2],
    ]
  end

  it 'should get neighbour coordinates for a top left cell' do
    field <<-EOF
    . .
    . .
    EOF
    @analyser.neighbours_of(0,0).should == [
            [0,1],
      [1,0],[1,1]
    ]
  end

  it 'should get neighbour coordinates for a bottom right cell' do
    field <<-EOF
    . . .
    . . .
    . . .
    EOF
    @analyser.neighbours_of(2,2).should == [
      [1,1],[1,2],
      [2,1]
    ]
  end
end