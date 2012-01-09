$: << File.dirname(__FILE__)+'/../lib'

require 'minesweeper/robot'
require 'minesweeper/game'

describe Minesweeper::Robot do
  it 'should get initial field' do
    g = Minesweeper::Game.new rows: 2, cols: 2, mine_count: 1
    g.field.should == [
      [:unknown, :unknown],
      [:unknown, :unknown]
    ]
  end
end