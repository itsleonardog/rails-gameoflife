require 'rails_helper'

RSpec.describe GameController, type: :controller do
  let(:cell) { Cell.create!(row: 1, column: 1, alive: true) }

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @grid' do
      get :index
      expect(assigns(:grid)).to eq(Cell.all.order(:row, :column))
    end
  end

  describe 'POST #play' do
    context 'when simulation is stopped' do
      it 'starts the simulation' do
        post :play
        expect(assigns(:simulation_state)).to eq(:running)
      end
    end
  end

  describe 'POST #stop' do
    context 'when simulation is running' do
      before do
        post :play
      end

      it 'stops the simulation' do
        post :stop
        expect(assigns(:simulation_state)).to eq(:stopped)
      end
    end
  end
end
