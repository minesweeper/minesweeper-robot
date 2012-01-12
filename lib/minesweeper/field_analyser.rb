require 'minesweeper/cell_sequence'
require 'minesweeper/single_mine_cluster'
require 'ruby-debug'
require 'set'

class Minesweeper::FieldAnalyser
  include Enumerable

  attr_reader :rows, :cols, :mines

  def initialize field,mines=1
    @mines = mines
    @field = field
    @rows = field.length
    @cols = field.map(&:length).max
    @size = rows * cols
  end

  def count_for_status status
    count {|r,c,s| s == status }
  end

  def remaining_mine_count
    mines - count_for_status('marked')
  end

  def status_at row, col
    @field[row][col]
  end

  def clusters_around row, col
    clusters = []
    with_adjacent_mine_count(status_at(row,col)) do |count|
      remaining_mine_count = count - neighbours_of(row, col).marked.count
      unclicked_cells = neighbours_of(row, col).unclicked.all
      if Minesweeper.adjacent? *unclicked_cells and remaining_mine_count > 0
        clusters << Minesweeper::MineCluster.new(remaining_mine_count, unclicked_cells)
      end
    end
    clusters
  end

  def probability_of_mine_at row, col
    current = remaining_mine_count.to_f/count_for_status('unclicked')
    each_neighbour_of row, col do |r,c,s|
      with_adjacent_mine_count s do |count|
        chance = (count-neighbours_of(r,c).marked.count).to_f/neighbours_of(r,c).unclicked.count
        current = chance if chance > current
      end
    end
    current
  end

  def least_likely_to_be_mined
    cell,likelihood  = nil, 1.0
    each do |r,c,s|
      next unless s == 'unclicked'
      new_likelihood = probability_of_mine_at r,c
      raise "Calculated insane probability of #{new_likelihood}" if new_likelihood < 0.0 or new_likelihood > 1.0
      cell,likelihood = [r,c], new_likelihood if new_likelihood < likelihood
    end
    puts "    Picked cell #{cell.inspect} with likelihood #{likelihood}"
    cell
  end

  def with_adjacent_mine_count status
    yield $1.to_i if status =~ /mines(\d)/
  end

  def each
    @rows.times do |row|
      @cols.times do |col|
        yield row, col, @field[row][col]
      end
    end
  end

  def all
    Minesweeper::CellSequence.new self, to_a
  end

  def each_neighbour_of row,col
    (row-1..row+1).map do |r|
      (col-1..col+1).map do |c|
        yield r, c, @field[r][c] unless (row == r and col == c) or r < 0 or c < 0 or r >= @rows or c >= @cols
      end
    end
  end

  def neighbours_of row, col
    cells = []
    each_neighbour_of(row,col) {|r,c,s| cells << [r,c,s] }
    Minesweeper::CellSequence.new self, cells
  end

  def safe_cells_to_click
    cells = []
    each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        marked_count = neighbours_of(row,col).marked.count
        unclicked_neighbours = neighbours_of(row,col).unclicked
        cells += unclicked_neighbours.all if marked_count == mine_count
      end
    end
    cells.uniq
  end

  def clusters
    clusters = []
    each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        clusters += clusters_around(row, col)
      end
    end
    clusters
  end

  def intersecting_clusters_for row, col
    result = []
    unclicked = Set.new neighbours_of(row,col).unclicked.all
    clusters.each do |cluster|
      result << cluster if cluster.subset? unclicked
    end
    result
  end

  def obvious_mines
    cells = []
    all_clusters = clusters
    each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        marked_count = neighbours_of(row,col).marked.count
        unclicked_neighbours = neighbours_of(row,col).unclicked
        if mine_count == (marked_count + unclicked_neighbours.count)
          cells += unclicked_neighbours.all
        else
          intersecting_clusters_for(row,col).each do |cluster|
            unclicked_cells_outside_cluster = unclicked_neighbours.all - cluster.cells
            if !unclicked_cells_outside_cluster.empty? and mine_count == (marked_count + cluster.count + unclicked_cells_outside_cluster.count)
              puts "    #{unclicked_cells_outside_cluster.inspect} seem likely to be mines considering #{[row,col].inspect} and cluster #{cluster.cells} (#{cluster.count})"
              cells += unclicked_cells_outside_cluster
            end
          end
        end
      end
    end
    cells.uniq
  end
end