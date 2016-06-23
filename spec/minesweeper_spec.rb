$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper'
require 'spec_helper'

describe Minesweeper do
  include Minesweeper

  describe 'adjacent_to?' do
    it 'should not recognise an empty list as adjacent' do
      adjacent?.should be false
    end

    it 'should not recognise a single cell as adjacent' do
      adjacent?([0,0]).should be false
    end

    it 'should recognise two adjacent horizonal cells as adjacent' do
      adjacent?([0,0],[0,1]).should be true
    end

    it 'should not recognise two non-adjacent horizonal cells as adjacent' do
      adjacent?([0,0],[0,2]).should be false
    end

    it 'should recognise two adjacent vertical cells as adjacent' do
      adjacent?([0,0],[1,0]).should be true
    end

    it 'should not recognise two non-adjacent vertical cells as adjacent' do
      adjacent?([0,0],[2,0]).should be false
    end

    it 'should recognise three adjacent vertical cells as adjacent' do
      adjacent?([2,0],[0,0],[1,0]).should be true
    end

    it 'should not recognise three non-adjacent vertical cells as adjacent' do
      adjacent?([0,0],[2,0],[3,0]).should be false
    end

    it 'should recognise top left to bottom right diagonally adjacent cells as adjacent' do
      adjacent?([0,0],[1,1]).should be true
    end

    it 'should recognise top right to bottom left diagonally adjacent cells as adjacent' do
      adjacent?([0,1],[1,0]).should be true
    end

    it 'should not recognise top left to bottom right diagonally non adjacent cells as adjacent' do
      adjacent?([0,0],[2,2]).should be false
    end

    it 'should not recognise diagonal arc as adjacent' do
      adjacent?([0,0],[1,1],[0,2]).should be false
    end

    it 'should not recognise right angle as adjacent' do
      adjacent?([0, 3], [1, 3], [2, 1], [2, 2], [2, 3]).should be false
    end
  end
end
