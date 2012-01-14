$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field'
require 'minesweeper/field_analyser'

describe Minesweeper::FieldAnalyser do
  include Minesweeper

  def analyse status_grid_string, mine_count=1
    @analyser = Minesweeper::FieldAnalyser.new create_field(status_grid_string, mine_count)
  end

  attr_reader :analyser

  it 'should calculate mine placement probability when there are no marked mines' do
    analyse <<-EOF, 1
    . .
    . .
    EOF
    analyser.probability_of_mine_at(0,0).should be_within(0.001).of(0.25)
  end

  it 'should calculate mine placement probability when there are marked mines' do
    analyse <<-EOF, 2
    . .
    . *
    EOF
    analyser.probability_of_mine_at(0,0).should be_within(0.001).of(0.333)
  end

  it 'should calculate mine placement probability considering adjacent revealed cells' do
    analyse <<-EOF, 1
    1 . .
    . . .
    EOF
    analyser.probability_of_mine_at(0,1).should be_within(0.001).of(0.333)
  end

  it 'should calculate mine placement probability considering each neighbour with revealed mine count and their adjacent revealed cells' do
    analyse <<-EOF, 1
    1 . .
    1 . .
    EOF
    analyser.probability_of_mine_at(0,1).should be_within(0.001).of(0.5)
  end

  it 'should calculate mine placement probability considering each neighbour with revealed mine count and their adjacent revealed mines' do
    analyse <<-EOF, 1
    2 . .
    * . .
    EOF
    analyser.probability_of_mine_at(0,1).should be_within(0.001).of(0.5)
  end

  it 'should calculate mine placement probability considering adjacent revealed cells and their adjacent mines' do
    analyse <<-EOF, 1
    . . . . .
    . 2 * 2 .
    . . 2 . .
    . . 2 2 .
    . . . . .
    EOF
    analyser.probability_of_mine_at(2,3).should be_within(0.001).of(0.333)
  end

  describe 'safe cells to click' do
    it 'should determine safe cells to left click' do
      analyse <<-EOF
      * 1
      . .
      EOF
      analyser.safe_cells_to_click.should == [[1,0],[1,1]]
    end

    it 'should determine safe cells to left click' do
      analyse <<-EOF
      * 1 .
      2 . .
      * 2 .
      EOF
      analyser.safe_cells_to_click.should == [
                [0,2],
          [1,1],[1,2]
      ]
    end

    it 'should detect a safe cell to click taking an adjacent cell cluster into consideration' do
      analyse <<-EOF
      0 0 0 .
      1 1 2 .
      . . . .
      EOF
      pending { analyser.safe_cells_to_click.should == [[0, 3], [1, 3], [2,2]] }
    end
  end

  describe 'obvious mines' do
    it 'should detect an obvious mine' do
      analyse <<-EOF
      . 1
      1 1
      EOF
      analyser.obvious_mines.should == [[0,0]]
    end

    it 'should detect an obvious mine' do
      analyse <<-EOF
      . 2 .
      1 2 1
      . . .
      EOF
      analyser.obvious_mines.should == [[0,0], [0,2]]
    end

    it 'should detect an obvious mine' do
      analyse <<-EOF
      . 1 .
      2 3 2
      1 . .
      EOF
      analyser.obvious_mines.should == [[0,0], [2,1]]
    end

    it 'should detect an obvious mine' do
      analyse <<-EOF
      0 0 1 1 .
      0 0 1 * .
      0 0 1 . .
      1 1 1 . .
      . . . . .
      EOF
      analyser.obvious_mines.should == []
    end

    it 'should detect an obvious mine taking an adjacent cell cluster into consideration' do
      analyse <<-EOF
      0 0 0 .
      1 2 2 .
      . . . .
      EOF
      analyser.obvious_mines.should == [[2,2]]
    end
  end

  describe 'clusters' do
    it 'should find a cluster around a numbered cell' do
      analyse <<-EOF
      0 0 0 .
      1 2 2 .
      . . . .
      EOF
      cluster1,cluster2 = stub('cluster1'),stub('cluster2')
      Minesweeper::MineCluster.should_receive(:new).once.with(1,[[2,0],[2,1]]).and_return cluster1
      Minesweeper::MineCluster.should_receive(:new).once.with(2,[[2,0],[2,1],[2,2]]).and_return cluster2
      analyser.clusters.should == [cluster1, cluster2]
    end

    it 'should not find a cluster around a numbered cell considering marked cells' do
      analyse <<-EOF
      1 1 .
      1 * .
      . . .
      EOF
      Minesweeper::MineCluster.should_not_receive :new
      analyser.clusters.should == []
    end

    it 'should find an intersecting cluster' do
      analyse <<-EOF
      0 0 0 .
      1 2 2 .
      . . . .
      EOF
      analyser.intersecting_clusters_for(1,1).size.should == 2
    end
  end
end