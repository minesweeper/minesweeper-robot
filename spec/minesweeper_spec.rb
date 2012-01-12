$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper'

describe Minesweeper do
  describe 'adjacent_to?' do
    it 'should not recognise an empty list as adjacent' do
      Minesweeper.adjacent?.should be_false
    end

    it 'should not recognise a single cell as adjacent' do
      Minesweeper.adjacent?([0,0]).should be_false
    end

    it 'should recognise two adjacent horizonal cells as adjacent' do
      Minesweeper.adjacent?([0,0],[0,1]).should be_true
    end

    it 'should not recognise two non-adjacent horizonal cells as adjacent' do
      Minesweeper.adjacent?([0,0],[0,2]).should be_false
    end

    it 'should recognise two adjacent vertical cells as adjacent' do
      Minesweeper.adjacent?([0,0],[1,0]).should be_true
    end

    it 'should not recognise two non-adjacent vertical cells as adjacent' do
      Minesweeper.adjacent?([0,0],[2,0]).should be_false
    end

    it 'should recognise three adjacent vertical cells as adjacent' do
      Minesweeper.adjacent?([2,0],[0,0],[1,0]).should be_true
    end

    it 'should not recognise three non-adjacent vertical cells as adjacent' do
      Minesweeper.adjacent?([0,0],[2,0],[3,0]).should be_false
    end

    it 'should recognise top left to bottom right diagonally adjacent cells as adjacent' do
      Minesweeper.adjacent?([0,0],[1,1]).should be_true
    end

    it 'should recognise top right to bottom left diagonally adjacent cells as adjacent' do
      Minesweeper.adjacent?([0,1],[1,0]).should be_true
    end

    it 'should not recognise top left to bottom right diagonally non adjacent cells as adjacent' do
      Minesweeper.adjacent?([0,0],[2,2]).should be_false
    end

    it 'should recognise diagonal arc as adjacent (even that makes no sense)' do
      Minesweeper.adjacent?([0,0],[1,1],[0,2]).should be_true
    end
  end
end