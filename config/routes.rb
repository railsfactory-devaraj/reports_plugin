# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
resources :reports, :only => [:new, :create]
post '/get-projects/:client_id', :to => 'reports#get_projects'
post '/get-users/:project_id', :to => 'reports#get_users'
get '/get-report', :to => 'reports#get_report', defaults: { format: 'xlsx' }
get '/get-clients', :to => 'reports#get_clients'
get '/get-client-projects', :to => 'reports#get_client_projetcs'
