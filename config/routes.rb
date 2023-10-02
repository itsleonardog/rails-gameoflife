Rails.application.routes.draw do
  root 'game#index'
  post 'game/play', to: 'game#play'
  post 'game/stop', to: 'game#stop'
end
