$: << File.dirname(__FILE__)+'/../lib'

require 'minesweeper/robot'
require 'minesweeper/game'

describe Minesweeper::Robot do
  attr_reader :game
 
  before :all do
    @game = Minesweeper::Game.new
  end

  after :all do
    game.destroy
  end

  def with_game field_string
    lines = field_string.split("\n").map &:split
    mines = []
    lines.each_with_index do |row, rindex|
      row.each_with_index { |col, cindex| mines << [rindex, cindex] if col == '*' }
    end
    game.reset rows: lines.length, cols: lines.map(&:length).max, mines: mines, mineCount: mines.length
  end

  it 'should get initial field containing only unknown status' do
    with_game <<-EOF
    . .
    . .
    EOF
    game.field.should == [
      [:unclicked, :unclicked],
      [:unclicked, :unclicked]
    ]
  end

  it 'should win the game if the mine is clicked' do
    with_game <<-EOF
    . *
    EOF
    game.click 0, 0
    game.field.should == [
      [:mines1, :unclicked]
    ]
    game.should be_won
  end
end