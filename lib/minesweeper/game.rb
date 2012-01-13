require 'minesweeper'
require 'watir-webdriver'
require 'nokogiri'
require 'json'

class Minesweeper::Game
  MAP = Hash[*%w{. unclicked * mine}]
  (0..9).each {|index| MAP[index.to_s] = "mines#{index}"}

  def self.string_to_field field_string
    field_string.split("\n").map do |row|
      row.split.map {|cell| MAP[cell]}
    end
  end

  def initialize
    @browser = Watir::Browser.start 'file://localhost/scratch/github/minesweeper/minesweeper.github.com/index.html?blank=true'
  end

  def reset options
    @browser.refresh
    @browser.execute_script "FieldPresenter.append('#minesweepers', #{options.to_json});"
  end

  def field
    table = Nokogiri::HTML @browser.div(:id, 'g1').table.html
    table.css('tr').map do |row|
      row.css('td').map {|cell| cell[:class] }
    end
  end

  def click row, col
    cell(row,col).click
  end

  def right_click row, col
    cell(row,col).right_click
  end

  def won?
    status? 'status won'
  end

  def lost?
    status? 'status dead'
  end

  def finished?
    won? or lost?
  end

  def destroy
    @browser.close
  end

  private

  def status? status
    @browser.span(id: 'g1indicator').class_name == status
  end

  def cell row, col
    @browser.td(id: "g1r#{row}c#{col}")
  end
end