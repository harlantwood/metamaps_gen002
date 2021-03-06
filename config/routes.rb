Metamaps::Application.routes.draw do

  root to: 'main#home', via: :get
  
  get 'request', to: 'main#requestinvite', as: :request
  
  get 'search/topics', to: 'main#searchtopics', as: :searchtopics
  get 'search/maps', to: 'main#searchmaps', as: :searchmaps
  get 'search/mappers', to: 'main#searchmappers', as: :searchmappers
  get 'search/synapses', to: 'main#searchsynapses', as: :searchsynapses
  
  namespace :api, path: '/api/v1', defaults: {format: :json} do
    resources :maps, only: [:create, :show, :update, :destroy]
    resources :synapses, only: [:create, :show, :update, :destroy]
    resources :topics, only: [:create, :show, :update, :destroy]
    resources :mappings, only: [:create, :show, :update, :destroy]
    resources :tokens, only: [ :create, :destroy] do
      get :my_tokens, on: :collection
    end 
  end
 
  resources :mappings, except: [:index, :new, :edit]
  resources :metacode_sets, :except => [:show]
  resources :metacodes, :except => [:show, :destroy]
  resources :synapses, except: [:index, :new, :edit]
  resources :topics, except: [:index, :new, :edit] do
    get :autocomplete_topic, :on => :collection
  end
  get 'topics/:id/network', to: 'topics#network', as: :network
  get 'topics/:id/relative_numbers', to: 'topics#relative_numbers', as: :relative_numbers
  get 'topics/:id/relatives', to: 'topics#relatives', as: :relatives
  
  resources :maps, except: [:index, :new, :edit]
  get 'explore/active', to: 'maps#activemaps'
  get 'explore/featured', to: 'maps#featuredmaps'
  get 'explore/mine', to: 'maps#mymaps'
  get 'explore/mapper/:id', to: 'maps#usermaps'

  get 'maps/:id/contains', to: 'maps#contains', as: :contains
  post 'maps/:id/upload_screenshot', to: 'maps#screenshot', as: :screenshot
  
  devise_for :users, controllers: { registrations: 'users/registrations', passwords: 'users/passwords', sessions: 'devise/sessions' }, :skip => :sessions

  devise_scope :user do 
    get 'login' => 'devise/sessions#new', :as => :new_user_session
    post 'login' => 'devise/sessions#create', :as => :user_session
    get 'logout' => 'devise/sessions#destroy', :as => :destroy_user_session
    get 'join' => 'devise/registrations#new', :as => :new_user_registration_path
  end

  get 'users/:id/details', to: 'users#details', as: :details
  post 'user/updatemetacodes', to: 'users#updatemetacodes', as: :updatemetacodes
  resources :users, except: [:index, :destroy]
end
