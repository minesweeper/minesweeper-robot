module Minesweeper
  MAP = Hash[*%w{. unclicked * marked ! mine}]
  (0..9).each {|index| MAP[index.to_s] = "mines#{index}"}

  def self.string_to_field field_string
    field_string.split("\n").map do |row|
      row.split.map {|cell| MAP[cell]}
    end
  end
end