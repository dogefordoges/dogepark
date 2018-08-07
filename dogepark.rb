# coding: utf-8
require 'sinatra'
require 'json'

@@users = {}
@@accounts = {}
@@bowls = {}

def new_user(username, password)
  address = "0x123212321232123212324567"
  @@users[username] = {:password => password, :address => address}
  @@accounts[address] = {:balance => 420.4242424242, :bowls => []}
end

get '/' do
  erb :index, :locals => { :signed_up => "\" \"" }
end

post '/signin' do
  payload = JSON.parse(request.body.read)
  username = payload['username']
  password = payload['password']
  if password && username
    if @@users.has_key? username
      if @@users[username][:password] == password
        @@users[username][:signed_in] = true
        redirect "/dogepark?username=" + username
      else
        {:message => "password incorrect"}.to_json
      end
    else
      {:message => "not signed up"}.to_json
    end
  else
    halt(404)
  end
end

post '/signup' do
  payload = JSON.parse(request.body.read)
  username = payload['username']
  password = payload['password']
  if password && username
    new_user(username, password)
    {:message => "signed up"}.to_json
  else
    halt(404)
  end
end

get '/dogepark' do
  username = params['username']
  if @@users.has_key? username
    if @@users[username][:signed_in] = true
      erb :dogepark, :locals => {
            :address => @@users[username][:address],
            :username => username
          }
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

def verify_user(username, password, &block)
  if @@users.has_key? username
    if @@users[username][:password] == password
      block.call
    else
      status 403
      body "Password is incorrect"
    end
  else
    status 500
    body "User not found"
  end
end

post '/location' do

  payload = JSON.parse(request.body.read)
  username = payload["username"]
  password = payload["password"]
  latitude = payload["latitude"]
  longitude = payload["longitude"]

  verify_user(username, password) do
    @@users[username][:latitude] = latitude
    @@users[username][:longitude] = longitude
    {:message => "Location saved!"}.to_json
  end
  
end

post '/withdraw' do
  payload = JSON.parse(request.body.read)
  username = payload["username"]
  password = payload["password"]  
  address = payload["address"]
  withdraw_address = payload["withdrawAddress"]
  amount = payload["amount"]

  verify_user(username, password) do
    {:message => "#{amount} Ð was sent from your account to #{withdraw_address}"}.to_json
  end

end

post '/rain' do
  payload = JSON.parse(request.body.read)
  username = payload["username"]
  password = payload["password"]
  address = payload["address"]
  latitude = payload["latitude"]
  longitude = payload["longitude"]
  amount = payload["amount"]
  radius = payload["radius"]

  verify_user(username, password) do
    {:message => "You made it rain #{amount} Ð on 20 shibes in a #{radius} km radius around coordinate #{latitude} lat, #{longitude} long"}.to_json
  end
  
end

post '/bowl' do
  payload = JSON.parse(request.body.read)
  username = payload["username"]
  password = payload["password"]
  address = payload["address"]
  bowl_amount = payload["bowlAmount"]
  bite_amount = payload["biteAmount"]

  verify_user(username, password) do
    {:message => "Here is your new bowl code: 0x123456. Total of #{bowl_amount/bite_amount} bites at #{bite_amount} Ð a piece"}.to_json
  end
end

post '/bite' do
  payload = JSON.parse(request.body.read)
  address = payload["address"]
  bowl_code = payload["bowlCode"]

  {:message => "You got a bite of 20 Ð!"}.to_json
end

get '/rainlogs' do
  address = params["address"]
  {:rainLogs => [
     "0x12345678 made it rain in your area! You received 20 Ð!",
     "0x15432452 made it rain in your area! You received 123456789 Ð!",
     "0x12346571 made it rain in your area! You received 420 Ð!"
   ]
  }.to_json
end

get '/bowls' do
  address = params["address"]
  {:bowls => [
     {:bowlCode => "0x12345678", :bowlAmount => 420.35},
     {:bowlCode => "0x12345678", :bowlAmount => 32.76},
     {:bowlCode => "0x12345678", :bowlAmount => 98.98}
   ]
  }.to_json
end

not_found do
  'Oh no! Something went wrong!'
end
