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


  end
end