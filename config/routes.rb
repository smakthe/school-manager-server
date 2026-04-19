Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post 'login', to: 'authentications#create'

      namespace :admin do
        resources :schools do
          collection do
            get :board_stats
          end
        end
        resources :teachers
        resources :students
        resources :classrooms
        resources :academic_years
        resources :teacher_subject_assignments, only: [:index, :create, :destroy]
        resources :marks, only: [:index]
        get 'dashboard_stats', to: 'dashboard#stats'
      end

      namespace :principal do
        resources :teachers
        resources :students
        resources :classrooms
        resources :marks, only: [:index]
        resources :teacher_subject_assignments, only: [:index]
        get 'dashboard_stats', to: 'dashboard#stats'
      end

      namespace :teacher do
        resources :classrooms, only: [:index, :show]
        resources :students, only: [:index, :show, :update]
        resources :marks, only: [:index, :create, :update]
        resources :teacher_subject_assignments, only: [:index]
        get 'dashboard_stats', to: 'dashboard#stats'
      end
    end
  end
end
