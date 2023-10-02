require 'rails_helper'

RSpec.describe GameChannel, type: :channel do
  before do
    # Simula una connessione al canale
    stub_connection
  end

  it 'subscribes and streams from game_channel' do
    # Simula una sottoscrizione al canale
    subscribe

    # Verifica che la sottoscrizione sia stata effettuata con successo
    expect(subscription).to be_confirmed

    # Verifica che il canale stia trasmettendo dallo stream corretto
    expect(subscription).to have_stream_from('game_channel')
  end
end
