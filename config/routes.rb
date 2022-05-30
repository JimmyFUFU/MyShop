Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  devise_for :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/', to: redirect('/products')

  # Product
  resources :products, only: [:index]

  # Cart
  resource :cart, only: [] do
    get '/', to: 'carts#show'
    get '/:cart_token', to: 'carts#show', as: :cart_token
    post '/item', to: 'carts#add_item'
    delete '/item', to: 'carts#remove_item'
  end

  # Order
  resources :orders, only: %i[index create] do
    collection do
      get '/:token', to: 'orders#show', as: :show
    end
  end
end
