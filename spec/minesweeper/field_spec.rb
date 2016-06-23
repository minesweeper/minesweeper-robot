$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field'
require 'spec_helper'

describe Minesweeper::Field do
  include Minesweeper

  it 'should iterate over all cells' do
    create_field(<<-EOF, 1).to_a.should == [[0,0,'marked'],[0,1,'mines1']]
    * 1
    EOF
  end

  it 'should determine row count' do
    create_field(<<-EOF, 1).row_count.should == 3
    . .
    . .
    . .
    EOF
  end

  it 'should determine col count' do
    create_field(<<-EOF, 1).col_count.should == 2
    . .
    . .
    . .
    EOF
  end

  it 'should get neighbour coordinates for a middle cell' do
    create_field(<<-EOF, 1).neighbours_of(1,1).all.should == [
    . . .
    . . .
    . . .
    EOF
      [0,0],[0,1],[0,2],
      [1,0],      [1,2],
      [2,0],[2,1],[2,2],
    ]
  end

  it 'should get neighbour coordinates for a top left cell' do
    create_field(<<-EOF, 1).neighbours_of(0,0).all.should == [
    . .
    . .
    EOF
            [0,1],
      [1,0],[1,1]
    ]
  end

  it 'should get neighbour coordinates for a bottom right cell' do
    create_field(<<-EOF, 1).neighbours_of(2,2).all.should == [
    . . .
    . . .
    . . .
    EOF
      [1,1],[1,2],
      [2,1]
    ]
  end

  it 'should get neighbour statuses' do
    create_field(<<-EOF, 1).neighbours_of(1,1).cells.should == [
    * 1 .
    2 . .
    * 2 .
    EOF
      [0,0,'marked'  ],[0,1,'mines1'],[0,2,'unclicked'],
      [1,0,'mines2'],                 [1,2,'unclicked'],
      [2,0,'marked'  ],[2,1,'mines2'],[2,2,'unclicked'],
    ]
  end
end
