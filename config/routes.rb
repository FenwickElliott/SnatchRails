Rails.application.routes.draw do
  devise_for :users
  
  get 'snatch/about'
  get 'snatch/options'
  get 'snatch/snatch'
  get 'snatch/fail'
  get 'snatch/link'
  get 'snatch/guest_snatch'

  root 'snatch#about'
  get 'options' => 'snatch#options'
  get 'snatch' => 'snatch#snatch'
  get 'guest_snatch' => 'snatch#guest_snatch'

  get '/auth/:provider/callback', to: 'snatch#link'
  get '/auth/failure' , to: 'snatch#fail'

  put 'snatch/options' => 'snatch#update'

  namespace :api do
    namespace :v1 do
      resources :users
    end
  end

end
