$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field_analyser'

describe Minesweeper::FieldAnalyser do
  def field field_string, mines=1
    field = Minesweeper.string_to_field field_string
    @analyser = Minesweeper::FieldAnalyser.new field, mines
  end

  it 'should calculate mine placement probability when there are no marked mines' do
    field <<-EOF, 1
    . .
    . .
    EOF
    @analyser.probability_of_mine_at(0,0).should be_within(0.001).of(0.25)
  end

  it 'should calculate mine placement probability when there are marked mines' do
    field <<-EOF, 2
    . .
    . *
    EOF
    @analyser.probability_of_mine_at(0,0).should be_within(0.001).of(0.333)
  end

  it 'should calculate mine placement probability considering adjacent revealed cells' do
    field <<-EOF, 1
    1 . .
    . . .
    EOF
    @analyser.probability_of_mine_at(0,1).should be_within(0.001).of(0.333)
  end

  it 'should calculate mine placement probability considering each neighbour with revealed mine count and their adjacent revealed cells' do
    field <<-EOF, 1
    1 . .
    1 . .
    EOF
    @analyser.probability_of_mine_at(0,1).should be_within(0.001).of(0.5)
  end

  it 'should calculate mine placement probability considering each neighbour with revealed mine count and their adjacent revealed mines' do
    field <<-EOF, 1
    2 . .
    * . .
    EOF
    @analyser.probability_of_mine_at(0,1).should be_within(0.001).of(0.5)
  end

  it 'should calculate mine placement probability considering adjacent revealed cells and their adjacent mines' do
    field <<-EOF, 1
    . . . . .
    . 2 * 2 .
    . . 2 . .
    . . 2 2 .
    . . . . .
    EOF
    @analyser.probability_of_mine_at(2,3).should be_within(0.001).of(0.333)
  end

  it 'should iterate over all cells' do
    field <<-EOF
    * 1
    EOF
    @analyser.to_a.should == [
      [0,0,'marked'],[0,1,'mines1']
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
      [0,0,'marked'  ],[0,1,'mines1'],[0,2,'unclicked'],
      [1,0,'mines2'],               [1,2,'unclicked'],
      [2,0,'marked'  ],[2,1,'mines2'],[2,2,'unclicked'],
    ]
  end

  it 'should determine safe cells to left click' do
    field <<-EOF
    * 1
    . .
    EOF
    @analyser.safe_cells_to_click.should == [[1,0],[1,1]]
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

  it 'should detect an obvious mine' do
    field <<-EOF
    . 2 .
    1 2 1
    . . .
    EOF
    @analyser.obvious_mines.should == [[0,0], [0,2]]
  end

  it 'should detect an obvious mine' do
    field <<-EOF
    . 1 .
    2 3 2
    1 . .
    EOF
    @analyser.obvious_mines.should == [[0,0], [2,1]]
  end

  it 'should detect an obvious mine' do
    field <<-EOF
    0 0 1 1 .
    0 0 1 * .
    0 0 1 . .
    1 1 1 . .
    . . . . .
    EOF
    @analyser.obvious_mines.should == []
  end

  it 'should detect an obvious mine taking an adjacent cell cluster into consideration' do
    field <<-EOF
    0 0 0 .
    1 2 2 .
    . . . .
    EOF
    pending { @analyser.obvious_mines.should == [[2,2]] }
  end

  describe 'clusters_around' do
    it 'should find a cluster around a numbered cell' do
      field <<-EOF
      0 0 0 .
      1 2 2 .
      . . . .
      EOF
      cluster = stub 'cluster'
      Minesweeper::MineCluster.should_receive(:new).once.with(1,[[2,0], [2,1]]).and_return cluster
      @analyser.clusters_around(1,0).should == [cluster]
    end

    it 'should not find a cluster around a numbered cell considering marked cells' do
      field <<-EOF
      1 1 .
      1 * .
      . . .
      EOF
      Minesweeper::MineCluster.should_not_receive :new
      @analyser.clusters_around(1,0).should == []
    end
  end
end