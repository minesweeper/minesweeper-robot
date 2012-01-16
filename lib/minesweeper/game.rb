require 'minesweeper'
require 'watir-webdriver'
require 'nokogiri'
require 'json'
require 'securerandom'

class Minesweeper::Game
  MAP = Hash[*%w{. unclicked * mine}]
  (0..9).each {|index| MAP[index.to_s] = "mines#{index}"}

  URLS = {
      :al => "file:////Users/alscott/Projects/minesweeper.github.com/index.html",
      :mark => "file://localhost/scratch/github/minesweeper/minesweeper.github.com/index.html",
      :default => "minesweeper.github.com"
  }

  URLS_PARAMS = {
    :beginner => "?preset=beginner",
    :intermediate => "?preset=intermediate",
    :expert => "?preset=expert",
    :blank => "?blank=true",
    :default => ""
  }

  def initialize location=nil, url_params=nil
    location = (location || :default).to_sym
    url_params = (url_params || :default).to_sym
    @browser = Watir::Browser.start "#{URLS[location]}#{URLS_PARAMS[url_params]}"
  end

  def reset
    @browser.refresh
  end

  def build options
    @browser.refresh
    @browser.execute_script "FieldPresenter.append('#minesweepers', #{options.to_json});"
  end

  def row_count
    @browser.div(:id, 'g1').table.rows.size
  end

  def col_count
    @browser.div(:id, 'g1').table.row.cells.size
  end

  def mine_count
    @browser.div(:id => 'g1minesRemaining').attribute_value('title').to_i
  end

  def status_grid
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

  def save_screenshot
    dir = "#{Dir.getwd}/screenshots/"
    Dir.mkdir dir unless Dir.exists? dir
    @browser.driver.save_screenshot "screenshots/#{SecureRandom.uuid}.png"
  end

  def won?
    save_screenshot if status? 'status won'
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