$: << File.dirname(__FILE__)+'/../../lib'

require 'minesweeper/field'

describe Minesweeper::Field do
  def field field_string, mine_count
    array = Minesweeper.string_to_field field_string
    @field = Minesweeper::Field.new array, mine_count
  end

  it 'should iterate over all cells' do
    field <<-EOF, 1
    * 1
    EOF
    @field.to_a.should == [
      [0,0,'marked'],[0,1,'mines1']
    ]
  end
end