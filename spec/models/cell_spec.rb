require 'rails_helper'

RSpec.describe Cell, type: :model do
  describe 'Game of Life rules' do
    context 'when cell is alive' do
      it 'dies if it has fewer than two live neighbors' do
        cell = Cell.create(alive: true)
        cell.apply_game_of_life_rules(1)
        expect(cell.alive?).to be_falsey
      end

      it 'lives on if it has two live neighbors' do
        cell = Cell.create(alive: true)
        cell.apply_game_of_life_rules(2)
        expect(cell.alive?).to be_truthy
      end

      it 'lives on if it has three live neighbors' do
        cell = Cell.create(alive: true)
        cell.apply_game_of_life_rules(3)
        expect(cell.alive?).to be_truthy
      end

      it 'dies if it has more than three live neighbors' do
        cell = Cell.create(alive: true)
        cell.apply_game_of_life_rules(4)
        expect(cell.alive?).to be_falsey
      end
    end

    context 'when cell is dead' do
      it 'becomes alive if it has exactly three live neighbors' do
        cell = Cell.create(alive: false)
        cell.apply_game_of_life_rules(3)
        expect(cell.alive?).to be_truthy
      end

      it 'stays dead if it has fewer than three live neighbors' do
        cell = Cell.create(alive: false)
        cell.apply_game_of_life_rules(2)
        expect(cell.alive?).to be_falsey
      end

      it 'stays dead if it has more than three live neighbors' do
        cell = Cell.create(alive: false)
        cell.apply_game_of_life_rules(4)
        expect(cell.alive?).to be_falsey
      end
    end
  end
end
