# coding: utf-8
require 'sinatra'
require 'json'
require 'jwt'
require './database'

class DogeParkApp < Sinatra::Base

  def initialize
    super()

    @accounts = {}
    @hmac_secret = "foobar"
    @db = Database.new  
    
  end
  
  def new_user(username, password)
    address = "0x123212321232123212324567"
    @db.insert_user({name: username, password: password, public_key: "foo", private_key: "bar"})
    @accounts[address] = {:balance => 420.4242424242}
  end

  def gen_jwt_token(data)
    duration = 4 * 3600 # 4 hours
    expiration = Time.now.to_i + duration
    expiring_payload = { data: data, exp: expiration }
    JWT.encode expiring_payload, @hmac_secret, 'HS256'
  end

  def decode_jwt_token(token)
    begin
      JWT.decode token, @hmac_secret, true, { algorithm: 'HS256' }
    rescue JWT::ExpiredSignature
      {data: "Expired token"}
    end
  end

  def valid_token?(token)
    if token != nil
      decode_jwt_token(token).first()["data"] == "signed_in"
    else
      false
    end
  end

  get '/' do
    erb :index, :locals => { :signed_up => "\" \"" }
  end

  post '/signin' do
    payload = JSON.parse(request.body.read)
    username = payload['username']
    password = payload['password']
    if password && username
      user = @db.get_user(username)
      if user
        if user[:password] == password
          token = gen_jwt_token("signed_in")
          {:message => "welcome to dogepark!", :url => "/dogepark?username=#{username}&token=#{token}", :token => token}.to_json
        else
          {:message => "password incorrect", :url => "none"}.to_json
        end
      else
        {:message => "not signed up", :url => "none"}.to_json
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
      user = @db.get_user(username)
      if user
        {:message => "already signed up", :url => "none"}.to_json
      else
        new_user(username, password)
        {:message => "signed up", :url => "none"}.to_json
      end
    else
      halt(404)
    end
  end

  get '/dogepark' do
    username = params["username"]
    token = params["token"]
    
    if valid_token? token
      user = @db.get_user(username)
      if user
        erb :dogepark, :locals => {
              :address => user[:public_key],
              :username => username,
              :token => token
            }
      else
        redirect "/"
      end
    else
      redirect "/"
    end
  end

  def verify_token(token, &block)
    if valid_token? token
      block.call
    else
      status 403
      body "Invalid token"
    end
  end

  def verify_user(username, password, &block)
    user = @db.get_user(username)
    if user
      if user[:password] == password
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

  get '/balance' do
    address = params['address']
    token = params['token']

    verify_token(token) do
      if @accounts.has_key? address
        {:balance => @accounts[address][:balance]}.to_json
      else
        status 500
        body "Address not found"
      end
    end
  end


  post '/location' do

    payload = JSON.parse(request.body.read)
    username = payload["username"]
    password = payload["password"]
    latitude = payload["latitude"]
    longitude = payload["longitude"]
    token = payload["token"]

    verify_token(token) do
      verify_user(username, password) do
        @db.update_location(username, {latitude: latitude, longitude: longitude})
        {:message => "Location saved!"}.to_json
      end
    end
    
  end

  post '/withdraw' do
    payload = JSON.parse(request.body.read)
    username = payload["username"]
    password = payload["password"]  
    address = payload["address"]
    withdraw_address = payload["withdrawAddress"]
    amount = payload["amount"]
    token = payload["token"]

    verify_token(token) do
      verify_user(username, password) do
        {:message => "#{amount} Ð was sent from your account to #{withdraw_address}"}.to_json
      end
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
    token = payload["token"]

    verify_token(token) do
      verify_user(username, password) do
        {:message => "You made it rain #{amount} Ð on 20 shibes in a #{radius} km radius around coordinate #{latitude} lat, #{longitude} long"}.to_json
      end
    end
    
  end

  post '/bowl' do
    payload = JSON.parse(request.body.read)
    username = payload["username"]
    password = payload["password"]
    address = payload["address"]
    bowl_amount = payload["bowlAmount"]
    bite_amount = payload["biteAmount"]
    token = payload["token"]

    verify_token(token) do
      verify_user(username, password) do
        {:message => "Here is your new bowl code: 0x123456. Total of #{bowl_amount/bite_amount} bites at #{bite_amount} Ð a piece"}.to_json
      end
    end
    
  end

  post '/bite' do
    payload = JSON.parse(request.body.read)
    address = payload["address"]
    bowl_code = payload["bowlCode"]
    token = payload["token"]

    verify_token(token) do
      {:message => "You got a bite of 20 Ð!"}.to_json
    end
  end

  get '/rainlogs' do
    address = params["address"]
    token = params["token"]

    verify_token(token) do
      {:rainLogs => [
         "0x12345678 made it rain in your area! You received 20 Ð!",
         "0x15432452 made it rain in your area! You received 123456789 Ð!",
         "0x12346571 made it rain in your area! You received 420 Ð!"
       ]
      }.to_json
    end
  end

  get '/bowls' do
    address = params["address"]
    token = params["token"]
    
    verify_token(token) do
      {:bowls => [
         {:bowlCode => "0x12345678", :bowlAmount => 420.35},
         {:bowlCode => "0x12345678", :bowlAmount => 32.76},
         {:bowlCode => "0x12345678", :bowlAmount => 98.98}
       ]
      }.to_json
    end
  end

  not_found do
    'Oh no! Something went wrong!'
  end
  
end
