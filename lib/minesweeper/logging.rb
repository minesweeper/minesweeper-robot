require 'minesweeper'

module Minesweeper::Logging
  def info message
    puts message if ENV['INFO']
  end
end