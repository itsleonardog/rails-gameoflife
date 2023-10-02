class GameController < ApplicationController
  before_action :set_simulation_state

  def index
    # Carica i dati delle celle dal db e inizializza la griglia
    @grid = Cell.all.order(:row, :column)
  end

  def play
    return unless @simulation_state == :stopped

    @simulation_state = :running
    start_simulation
  end

  def stop
    return unless @simulation_state == :running

    stop_simulation

    # Comunica ai client WebSocket di aggiornare la griglia
    ActionCable.server.broadcast 'game_channel', action: 'update_grid', grid: updated_grid_data
    @simulation_state = :stopped
  end

  private

  def set_simulation_state
    # Imposta lo stato della simulazione come :stopped se non è stato impostato
    @simulation_state ||= :stopped
  end

  def start_simulation
    # Inizia la simulazione in un thread separato
    @simulation_timer = Thread.new do
      while @simulation_state == :running
        advance_game_step
        sleep(1)
      end
    end
  end

  def stop_simulation
    # Interrompi la simulazione uccidendo il thread se è ancora attivo
    @simulation_timer&.kill if @simulation_timer&.alive?
  end

  def advance_game_step
    grid = Cell.all.order(:row, :column)
    new_grid = Array.new(13) { Array.new(13, false) }

    update_cell_states(grid, new_grid)
    update_grid_with_new_states(grid, new_grid)
  end

  def update_cell_states(grid, new_grid)
    grid.each do |cell|
      row = cell.row
      col = cell.column
      neighbors = count_alive_neighbors(row, col)

      cell.apply_game_of_life_rules(neighbors)
      new_grid[row][col] = cell.alive?
    end
  end

  def update_grid_with_new_states(grid, new_grid)
    grid.each_with_index do |cell, index|
      cell.update(alive: new_grid[index / 13][index % 13])
    end
  end

  def count_alive_neighbors(row, col)
    # Definisce un array di posizioni relative delle celle adiacenti
    positions = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1],           [0, 1],
      [1, -1], [1, 0], [1, 1]
    ]
    alive_neighbors = 0
    # Loop attraverso le posizioni relative delle celle adiacenti
    positions.each do |(row_offset, col_offset)|
      new_row = row + row_offset
      new_col = col + col_offset

      # Verifica se la nuova posizione è valida all'interno della griglia
      next unless valid_position?(new_row, new_col)

      neighbor_cell = Cell.find_by(row: new_row, column: new_col)
      alive_neighbors += 1 if neighbor_cell&.alive?
    end
    alive_neighbors
  end

  def valid_position?(row, col)
    row.between?(0, 12) && col.between?(0, 12)
  end
end
