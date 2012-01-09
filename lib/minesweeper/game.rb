require 'watir-webdriver'
require 'nokogiri'
require 'json'

module Minesweeper; end

class Minesweeper::Game
  def initialize
    @browser = Watir::Browser.start 'minesweeper.github.com?blank=true'
  end

  def reset options
    @browser.refresh
    @browser.execute_script "FieldPresenter.append('#minesweepers', #{options.to_json});"
    self
  end

  def field
    table = Nokogiri::HTML @browser.div(:id, 'g1').table.html
    table.css('tr').map do |row|
      row.css('td').map {|cell| cell[:class].to_sym }
    end
  end

  def click row, col
    @browser.td(id: "g1r#{row}c#{col}").click
  end

  def won?
    true
  end

  def destroy
    @browser.close
  end
end