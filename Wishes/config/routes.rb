Rails.application.routes.draw do
	# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
=begin
	scope '/api' do
		scope '/v1' do
			scope '/users' do
				post '/login' => 'users#login'
				post '/signup' => 'users#create'

				scope '/:id' do
					get '/' => 'user#show'

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
						scope '/:id' do
							get '/' => 'wishes#show'
							get '/edit' => 'wishes#edit'
							put '' => 'wishes#update'
						end
					end
				end
			
			end
		end
	end
=end
end
