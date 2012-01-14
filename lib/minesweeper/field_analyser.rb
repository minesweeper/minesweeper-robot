require 'minesweeper/logging'
require 'minesweeper/cell_sequence'
require 'minesweeper/single_mine_cluster'
require 'ruby-debug'
require 'set'

class Minesweeper::FieldAnalyser
  include Minesweeper
  include Minesweeper::Logging

  attr_reader :field

  def initialize field
    @field = field
  end

  def probability_of_mine_at row, col
    current = field.remaining_mine_count.to_f/field.count_for_status('unclicked')
    field.each_neighbour_of row, col do |r,c,s|
      with_adjacent_mine_count s do |count|
        neighbours = field.neighbours_of r,c
        chance = (count-neighbours.marked.count).to_f/neighbours.unclicked.count
        current = chance if chance > current
      end
    end
    current
  end

  def least_likely_to_be_mined
    cell,likelihood  = nil, 1.0
    field.each do |r,c,s|
      next unless s == 'unclicked'
      new_likelihood = probability_of_mine_at r,c
      raise "Calculated insane probability of #{new_likelihood}" if new_likelihood < 0.0 or new_likelihood > 1.0
      cell,likelihood = [r,c], new_likelihood if new_likelihood < likelihood
    end
    info "    Picked cell #{cell.inspect} with likelihood #{likelihood}"
    cell
  end

  def clusters_around row, col
    clusters = []
    with_adjacent_mine_count(field.status_at(row,col)) do |count|
      neighbours = field.neighbours_of row, col
      remaining_mine_count = count - neighbours.marked.count
      unclicked_cells = neighbours.unclicked.all
      if adjacent? *unclicked_cells and remaining_mine_count > 0
        clusters << Minesweeper::MineCluster.new(remaining_mine_count, unclicked_cells)
      end
    end
    clusters
  end

  def clusters
    clusters = []
    field.each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        next if mine_count == 0
        clusters += clusters_around(row, col)
      end
    end
    clusters
  end

  def intersecting_clusters_for row, col
    result = []
    unclicked = Set.new field.neighbours_of(row,col).unclicked.all
    clusters.each do |cluster|
      result << cluster if cluster.subset? unclicked
    end
    result
  end

  def safe_cells_to_click
    cells = []
    field.each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        neighbours = field.neighbours_of row, col
        cells += neighbours.unclicked.all if neighbours.marked.count == mine_count
      end
    end
    cells.uniq
  end

  def obvious_mines
    cells = []
    all_clusters = clusters
    field.each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        next if mine_count == 0
        neighbours = field.neighbours_of(row,col)
        marked_count = neighbours.marked.count
        remaining_mines = mine_count - marked_count
        next if remaining_mines == 0
        unclicked_neighbours = neighbours.unclicked
        if remaining_mines == unclicked_neighbours.count
          cells += unclicked_neighbours.all
        else
          intersecting_clusters_for(row,col).each do |cluster|
            unclicked_cells_outside_cluster = unclicked_neighbours.all - cluster.cells
            if !unclicked_cells_outside_cluster.empty? and remaining_mines == (cluster.count + unclicked_cells_outside_cluster.count)
              info "    #{unclicked_cells_outside_cluster.inspect} seem likely to be mines considering #{[row,col].inspect} and cluster #{cluster.cells} (#{cluster.count})"
              cells += unclicked_cells_outside_cluster
            end
          end
        end
      end
    end
    cells.uniq
  end
end