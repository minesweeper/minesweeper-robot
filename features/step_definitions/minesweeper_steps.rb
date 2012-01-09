Given /^the field$/ do |field_string|
  lines = field_string.split("\n").map &:split
  mines = []
  lines.each_with_index do |row, rindex|
    row.each_with_index { |col, cindex| mines << [rindex, cindex] if col == '*' }
  end
  Minesweeper.game.reset rows: lines.length, cols: lines.map(&:length).max, mines: mines, mineCount: mines.length
end

When /^I click on the cell in the (\d+).. row and (\d+).. column$/ do |row, col|
  Minesweeper.game.click row.to_i-1, col.to_i-1
end

Then /^I should win$/ do
  Minesweeper.game.should be_won
end

Then /^I should see the game$/ do |field_string|
  map = Hash[*%w{. unclicked * mine}]
  (0..9).each {|index| map[index.to_s] = "mines#{index}"}
  Minesweeper.game.field.should == field_string.split("\n").map do |row|
    row.split.map {|cell| map[cell]}
  end
end