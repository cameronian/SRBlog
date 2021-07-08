Rails.application.routes.draw do
  get 'posts/tag'
  get 'contributor/ian'
  get 'contributor/index'

  get 'exception/not_found'
  get 'exception/error'

  get 'blog/index'
  get 'blog/show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'blog#index'

  match "/404", to: 'exception#not_found', via: :all
  match "/500", to: 'exception#error', via: :all

  #match '*path' => redirect('exception/index'), via: :all #unless Rails.env.development?
end
