Rails.application.routes.draw do
  get 'exchanges/index'
  get 'exchanges/success'
  get 'exchanges/fail'
  get 'exchanges/empty'
  get 'exchanges/error'
  post 'exchanges' => 'exchanges#create'
  get '*unmatched_route', to: 'application#render_404'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
