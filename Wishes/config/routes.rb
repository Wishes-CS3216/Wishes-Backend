Rails.application.routes.draw do
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

	scope '/api' do
		scope '/v1' do
			scope '/users' do
				post '/login' => 'users#login'
				post '/signup' => 'users#create'

				scope '/:user_id' do
					get '/' => 'users#show'
					put '/' => 'users#update'
					get '/getRandomWishes' => 'wishes#get_random_wishes'

					scope '/reports' do
						post '/' => 'reports#create'
					end

					scope '/activities' do
						get '/' => 'activities#index'
						post '/archive' => 'activities#archive'
					end

					scope '/wishes' do
						get '/' => 'wishes#index'
						post '/' => 'wishes#create' 
						scope '/:wish_id' do
							put '/' => 'wishes#update'
						end
					end
				end
			end

			scope '/wishes' do
				get '/:wish_id' => 'wishes#show'
			end

			scope '/leaderboard' do
				get '/' => 'leaderboard#show'
				get '/:user_id' => 'leaderboard#show_user_rank'
			end
		end
	end
end
