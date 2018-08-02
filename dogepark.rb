require 'sinatra'

@@users = {}

def new_user(username, password)
  @@users[username] = {:password => password, :balance => 420.424242, :address => "0x123212321232123212324567"}
end

get '/' do
  erb :index, :locals => {:signed_up => ""}
end

get '/dogepark' do
  erb :dogepark
end

get '/signin' do
  username = params['username']
  password = params['password']
  if password && username
    if @@users.has_key? username
      redirect "/dogepark"
    else
      erb :index, :locals => {:signed_up => "not signed up"}
    end
  else
    halt(404)
  end
end

get '/signup' do
  username = params['username']
  password = params['password']
  if password && username
    new_user(username, password)
    erb :index, :locals => {:signed_up => "signed up"}
  else
    halt(404)
  end
end

not_found do
  'This is nowhere to be found.'
end
