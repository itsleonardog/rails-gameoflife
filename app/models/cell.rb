class Cell < ApplicationRecord
  def apply_game_of_life_rules(neighbors)
    if alive?
      # Rule 1: Any live cell with fewer than two live neighbors dies.
      # Rule 3: Any live cell with more than three live neighbors dies.
      self.alive = false if neighbors < 2 || neighbors > 3
    elsif neighbors == 3
      # Rule 4: Any dead cell with exactly three live neighbors becomes alive.
      self.alive = true
    end
  end
end
