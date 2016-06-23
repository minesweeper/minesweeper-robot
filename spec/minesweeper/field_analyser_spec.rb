$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field'
require 'minesweeper/field_analyser'
require 'spec_helper'

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
      analyser.safe_cells_to_click.should == [[2,2]]
    end

    it 'should detect a safe cell to click taking an adjacent cell cluster with marked mines into consideration' do
      analyse <<-EOF
      1 2 .
      * 2 .
      1 3 .
      0 1 .
      1 2 .
      . . .
      EOF
      analyser.safe_cells_to_click.should == [[2,2]]
    end

    it 'should detect a safe cell taking multiple non-adjacent cell clusters into consideration' do
      analyse <<-EOF
      3 * 3 1 2 1
      * * 4 * 3 *
      3 4 . . . 2
      * 2 . 2 . 1
      EOF
      analyser.safe_cells_to_click.should == [[3, 2], [3, 4], [2, 3]]
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

    it 'should detect an obvious mine taking multiple adjacent cell clusters into consideration' do
      analyse <<-EOF
      0 0 1
      0 . .
      0 2 .
      0 4 .
      * * .
      . . .
      EOF
      analyser.obvious_mines.should == [[4,2]]
    end

    it 'should detect an obvious mine when taking two non-adjacent cell clusters into consideration' do
      analyse <<-EOF
      1 . 3 . 1
      1 . . . 1
      EOF
      analyser.obvious_mines.should == [[1,2]]
    end

  end

  describe 'clusters' do
    it 'should find a cluster around a numbered cell' do
      analyse <<-EOF
      0 0 0 .
      1 2 2 .
      . . . .
      EOF
      clusters = analyser.clusters
      clusters.count == 2
      clusters.first.count.should == 1
      clusters.first.cells.should == [[2,0],[2,1]]
      clusters.last.count.should == 2
      clusters.last.cells.should == [[2,0],[2,1],[2,2]]
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
      analyser.intersecting_clusters_for(analyser.clusters,1,1).size.should == 2
    end

    it 'should find a cluster taking into account marked mines' do
      analyse <<-EOF
      1 2 .
      * 2 .
      1 3 .
      0 1 .
      1 2 .
      . . .
      EOF
      clusters = analyser.clusters
      clusters.count.should == 5
      clusters[0].count.should == 1
      clusters[0].cells.should == [[0,2],[1,2]]
      clusters[1].count.should == 1
      clusters[1].cells.should == [[0,2],[1,2],[2,2]]
      clusters[2].count.should == 2
      clusters[2].cells.should == [[1,2],[2,2],[3,2]]
      clusters[3].count.should == 1
      clusters[3].cells.should == [[2,2],[3,2],[4,2]]
      clusters[4].count.should == 1
      clusters[4].cells.should == [[5,0],[5,1]]
    end

    it 'should find a derived cluster' do
      analyse <<-EOF
      0 0 1
      0 . .
      0 2 .
      0 4 .
      * * .
      . . .
      EOF
      clusters = analyser.clusters
      clusters.count.should == 2
      derived_clusters = analyser.derived_clusters clusters
      derived_clusters.count.should == 1
      derived_clusters.first.count.should == 1
      derived_clusters.first.cells.should == [[2,2],[3,2]]
    end

    it 'should find multiple adjacent cell clusters' do
      analyse <<-EOF
      3 * 3 1 2 1
      * * 4 * 3 *
      3 4 . . . 2
      * 2 . 2 . 1
      EOF
      clusters = analyser.clusters
      clusters.count.should == 4
      clusters[0].count.should == 1
      clusters[0].cells.should == [[2,2],[2,3]]
      clusters[1].count.should == 1
      clusters[1].cells.should == [[2,3],[2,4]]
      clusters[2].count.should == 1
      clusters[2].cells.should == [[2,2],[3,2]]
      clusters[3].count.should == 1
      clusters[3].cells.should == [[2,4],[3,4]]
    end

    it 'should find multiple non-adjacent cell clusters' do
      analyse <<-EOF
      1 . 3 . 1
      1 . . . 1
      EOF
      clusters = analyser.clusters
      clusters.count.should == 2
      clusters[0].count.should == 1
      clusters[0].cells.should == [[0,1],[1,1]]
      clusters[1].count.should == 1
      clusters[1].cells.should == [[0,3],[1,3]]
    end
  end
end
