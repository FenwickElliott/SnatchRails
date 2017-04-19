Rails.application.routes.draw do
  devise_for :users
  get 'snatch/about'
  get 'snatch/options'
  get 'snatch/snatch'

  root 'snatch#about'
  get 'options' => 'snatch#options'
  get 'snatch' => 'snatch#snatch'

  get '/auth/:provider/callback', to: 'snatch#about'
  get '/auth/failure' , to: 'snatch#options'

  put 'snatch/options' => 'snatch#update'

end
