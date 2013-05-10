require 'minesweeper/logging'
require 'minesweeper/cell_sequence'
require 'minesweeper/single_mine_cluster'
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
    cells,likelihood  = [], 1.0
    field.each do |r,c,s|
      next unless s == 'unclicked'
      new_likelihood = probability_of_mine_at r,c
      raise "Calculated insane probability of #{new_likelihood}" if new_likelihood < 0.0 or new_likelihood > 1.0
      cells << [r,c] if new_likelihood == likelihood
      cells,likelihood = [[r,c]], new_likelihood if new_likelihood < likelihood
    end

    cell = cells.first
    #cell = cells[(cells.size/2).to_i] #middle
    #cell = cells[rand(cells.size)] #random click
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
        clusters_around = clusters_around(row, col)
        clusters_around.each do |c_a|
          inc = false
          clusters.each do |c|
            inc = true if c.count == c_a.count and c.cells == c_a.cells
          end
          clusters << c_a unless inc
        end
      end
    end
    clusters
  end

  def intersecting_clusters_for all_clusters, row, col
    result = []
    unclicked = Set.new field.neighbours_of(row,col).unclicked.all
    all_clusters.each do |cluster|
      result << cluster if cluster.subset? unclicked
    end
    result
  end

  def derived_clusters all_clusters
    clusters = []
    field.each do |row, col, status|
      with_adjacent_mine_count status do |count|
        next if count == 0
        neighbours = field.neighbours_of row, col
        remaining_mine_count = count - neighbours.marked.count
        unclicked = Set.new neighbours.unclicked.all
        all_clusters.each do |cluster|
          if cluster.subset?(unclicked)
            other_cells = unclicked - Set.new(cluster.cells)
            count_in_new_cluster = remaining_mine_count - cluster.count
            if adjacent?(*other_cells) and remaining_mine_count > 0
              clusters << Minesweeper::MineCluster.new(count_in_new_cluster, other_cells.to_a)
            end
          end
        end
      end
    end
    clusters
  end

  def non_intersecting_clusters intersecting_clusters
    non_intersecting_clusters = []
    intersecting_clusters.each do |cluster|
      other_clusters  = Array.new(intersecting_clusters)
      other_clusters.delete cluster

      other_clusters.each do |other_cluster|
        if (cluster.cells & other_cluster.cells) == []
          unless non_intersecting_clusters.include? [cluster, other_cluster] or non_intersecting_clusters.include? [other_cluster, cluster]
            non_intersecting_clusters << [cluster, other_cluster]
          end
        end
      end
    end
    non_intersecting_clusters
  end


  def safe_cells_to_click
    cells = []
    all_clusters = clusters
    all_clusters += derived_clusters(clusters)
    field.each do |row, col, status|
      with_adjacent_mine_count status do |mine_count|
        next if mine_count == 0
        neighbours = field.neighbours_of row, col
        unclicked_neighbours = neighbours.unclicked
        if neighbours.marked.count == mine_count
          cells += unclicked_neighbours.all
        else
          intersecting_clusters = intersecting_clusters_for(all_clusters,row,col)
          non_intersecting_clusters = non_intersecting_clusters intersecting_clusters

          non_intersecting_clusters.each do |cluster_pair|
            unclicked_cells_outside_cluster_pair = unclicked_neighbours.all - cluster_pair.first.cells - cluster_pair.last.cells
            if !unclicked_cells_outside_cluster_pair.empty? and (mine_count - neighbours.marked.count) == (cluster_pair.first.count + cluster_pair.last.count)
               info "    #{unclicked_cells_outside_cluster_pair.inspect} seem likely to be safe to click considering #{[row,col].inspect} and two clusters #{cluster_pair.first.cells} (#{cluster_pair.first.count}) AND #{cluster_pair.last.cells} (#{cluster_pair.last.count})"
               cells += unclicked_cells_outside_cluster_pair
             end
          end

          intersecting_clusters.each do |cluster|
            unclicked_cells_outside_cluster = unclicked_neighbours.all - cluster.cells
            if !unclicked_cells_outside_cluster.empty? and mine_count - neighbours.marked.count == cluster.count
              info "    #{unclicked_cells_outside_cluster.inspect} seem likely to be safe to click considering #{[row,col].inspect} and cluster #{cluster.cells} (#{cluster.count})"
              cells += unclicked_cells_outside_cluster
            end
          end
        end
      end
    end
    cells.uniq
  end

  def obvious_mines
    cells = []
    all_clusters = clusters
    all_clusters += derived_clusters(clusters)
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
          intersecting_clusters = intersecting_clusters_for all_clusters, row, col
          non_intersecting_clusters = non_intersecting_clusters intersecting_clusters

          non_intersecting_clusters.each do |cluster_pair|
            unclicked_cells_outside_cluster_pair = unclicked_neighbours.all - cluster_pair.first.cells - cluster_pair.last.cells
            if !unclicked_cells_outside_cluster_pair.empty? and (remaining_mines == (cluster_pair.first.count + cluster_pair.last.count + unclicked_cells_outside_cluster_pair.count))
               info "    #{unclicked_cells_outside_cluster_pair.inspect} seem likely to be mines considering #{[row,col].inspect} and two clusters #{cluster_pair.first.cells} (#{cluster_pair.first.count}) AND #{cluster_pair.last.cells} (#{cluster_pair.last.count})"
               cells += unclicked_cells_outside_cluster_pair
             end
          end

          intersecting_clusters.each do |cluster|
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