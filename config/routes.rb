Rails.application.routes.draw do
  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'login#index'

  # General
  get "/logout" => "application#logout"
  get "/cas/logout" => "login#index" #for testing purposes
  get "/welcome" => "application#welcome"
  get "/user" => "application#index"
  get "/edit" => "application#edit"
  post "/update" => "application#update"
  post "/create" => 'application#create'
  get '/users/emails' => 'application#emails'
  post '/updateFilters' => 'application#updateFilters'

  # Professors
  resources :professors, only: [:index, :show] do
    get :all, :on => :collection
    get :distinguished, :on => :collection
  end

  # Courses
  resources :courses, only: [:index, :show] do
    get :all, :on => :collection
    get :schedule, :on => :collection
    get :compare, :on => :collection
  end
end
