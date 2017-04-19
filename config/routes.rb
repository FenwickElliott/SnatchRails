Rails.application.routes.draw do
  devise_for :users
  get 'snatch/about'
  get 'snatch/options'
  get 'snatch/link'
  get 'snatch/guest_snatch'
  get 'snatch/snatch'

  get 'snatch' => 'snatch#snatch'
  get 'options' => 'snatch#options'
  get 'link' => 'snatch#link'
  get 'guest_snatch' => 'snatch#guest_snatch'

  get '/auth/:provider/callback', to: 'snatch#about'
  get '/auth/failure' , to: 'snatch#options'

  put 'snatch/options' => 'snatch#update'

  root 'snatch#about'
end
