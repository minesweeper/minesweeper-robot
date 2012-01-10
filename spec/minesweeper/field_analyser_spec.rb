$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field_analyser'

describe Minesweeper::FieldAnalyser do
  def field field_string
    @analyser = Minesweeper::FieldAnalyser.new Minesweeper.string_to_field field_string
  end

  it 'should iterate over all cells' do
    field <<-EOF
    * 1
    EOF
    @analyser.to_a.should == [
      [0,0,'mine'],[0,1,'mines1']
    ]
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
    @analyser.neighbours_of(1,1).all.should == [
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
    @analyser.neighbours_of(0,0).all.should == [
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
    @analyser.neighbours_of(2,2).all.should == [
      [1,1],[1,2],
      [2,1]
    ]
  end

  it 'should get neighbour statuses' do
    field <<-EOF
    * 1 .
    2 . .
    * 2 .
    EOF
    @analyser.neighbours_of(1,1).cells.should == [
      [0,0,'mine'  ],[0,1,'mines1'],[0,2,'unclicked'],
      [1,0,'mines2'],               [1,2,'unclicked'],
      [2,0,'mine'  ],[2,1,'mines2'],[2,2,'unclicked'],
    ]
  end

  it 'should determine neighbours of a given status' do
    field <<-EOF
    * 1 .
    2 . .
    * 2 .
    EOF
    @analyser.neighbours_of_status(0,0,'mines1').should == [[0,1]]
    @analyser.neighbours_of_status(0,0,'mines2').should == [[1,0]]
    @analyser.neighbours_of_status(0,0,'unclicked').should == [[1,1]]
    @analyser.neighbours_of_status(0,0,'mine').should == []
    @analyser.neighbours_of_status(0,1,'mine').should == [[0,0]]
    @analyser.neighbours_of_status(0,1,'unclicked').should == [[0,2],[1,1],[1,2]]
    @analyser.neighbours_of_status(0,1,'mines2').should == [[1,0]]
    @analyser.neighbours_of_status(2,2,'mines2').should == [[2,1]]
    @analyser.neighbours_of_status(2,2,'unclicked').should == [[1,1],[1,2]]
  end

  it 'should determine safe cells to left click' do
    field <<-EOF
    * 1 .
    2 . .
    * 2 .
    EOF
    @analyser.safe_cells_to_click.should == [
              [0,2],
        [1,1],[1,2]
    ]
  end

  it 'should detect an obvious mine' do
    field <<-EOF
    . 1
    1 1
    EOF
    @analyser.obvious_mines.should == [[0,0]]
  end
end