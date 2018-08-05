require 'sinatra'
require 'json'

@@users = {}
@@accounts = {}

def new_user(username, password)
  address = "0x123212321232123212324567"
  @@users[username] = {:password => password, :address => address}
  @@accounts[address] = {:balance => 420.4242424242}
end

get '/' do
  erb :index, :locals => { :signed_up => "\" \"" }
end

get '/signin' do
  username = params['username']
  password = params['password']
  if password && username
    if @@users.has_key? username
      if @@users[username][:password] == password
        @@users[username][:signed_in] = true
        redirect "/dogepark?username=" + username
      else
        erb :index, :locals => {:signed_up => "\"password incorrect\""}
      end
    else
      erb :index, :locals => {:signed_up => "\"not signed up\""}
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
    erb :index, :locals => {:signed_up => "\"signed up\""}
  else
    halt(404)
  end
end

get '/dogepark' do
  username = params['username']
  if @@users.has_key? username
    if @@users[username][:signed_in] = true
      erb :dogepark, :locals => {:address => @@users[username][:address]}
    else
      redirect "/"
    end
  else
    redirect "/"
  end
end

get '/balance' do
  address = params['address']
  if @@accounts.has_key? address
    {:balance => @@accounts[address][:balance]}.to_json
  else
    status 500
    body "Address not found"
  end
end

not_found do
  'This is nowhere to be found.'
end
