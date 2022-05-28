Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/', to: redirect('/products')

  # Product
  resources :products, only: [:index]

  # Cart
  resource :carts, only: [] do
    get '/', to: 'carts#show'
    get '/:cart_token', to: 'carts#show', as: :cart_token
    post '/item', to: 'carts#add_item'
    delete '/item', to: 'carts#remove_item'
  end
end
