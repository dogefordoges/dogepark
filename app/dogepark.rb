# coding: utf-8
require 'sinatra'
require 'json'
require 'jwt'
require './app/database'
require 'geocoder'

Geocoder.configure(:units => :km)

class Sequel::Dataset
  def to_a
    arr = []
    all.each do |x|
      arr << x
    end
  end
end
  

class DogeParkApp < Sinatra::Base

  def initialize
    super()

    @accounts = {}
    @hmac_secret = "foobar"
    @db = Database.new
    @signed_in = {} # maps JWT tokens to user id's
    
  end
  
  def new_user(username, password)
    address = "0x#{rand(423456789234567..493456789234567)}"
    @db.insert_user({name: username, password: password, public_key: address, private_key: address})
    @accounts[address] = {:balance => 420.4242424242}
  end

  def gen_jwt_token(data, user_id)
    duration = 4 * 3600 # 4 hours
    expiration = Time.now.to_i + duration
    expiring_payload = { data: data, id: user_id, exp: expiration }
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

  post '/signup' do
    payload = JSON.parse(request.body.read)
    username = payload['username']
    password = payload['password']
    if password && username
      user = @db.get_user_by_name(username)
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

  post '/signin' do
    payload = JSON.parse(request.body.read)
    username = payload['username']
    password = payload['password']
    if password && username
      user = @db.get_user_by_name(username)
      if user
        if user[:password] == password
          token = gen_jwt_token("signed_in", user[:id])
          @signed_in[token] = user[:id]
          {:message => "welcome to dogepark!", :token => token}.to_json
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

  get '/dogepark' do
    token = params["token"]
    
    if valid_token? token
      id = @signed_in[token]
      user = @db.get_user(id)
      if user
        erb :dogepark, :locals => {
              :address => user[:public_key],
              :token => token
            }
      else
        redirect "/"
      end
    else
      @signed_in[token] = nil if @signed_in[token]
      redirect "/"
    end
  end

  def verify_token(token, &block)
    if valid_token? token
      block.call
    else
      @signed_in[token] = nil if @signed_in[token]        
      status 403
      body "Invalid token"
    end
  end

  def verify_user(id, password, &block)
    user = @db.get_user(id)
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
    token = params['token']

    verify_token(token) do
      id = @signed_in[token]
      user = @db.get_user(id)
      if @accounts.has_key? user[:public_key]
        {:balance => @accounts[user[:public_key]][:balance]}.to_json
      else
        status 500
        body "Address not found"
      end
    end
  end

  post '/location' do

    payload = JSON.parse(request.body.read)
    
    token = payload["token"]
    password = payload["password"]
    latitude = payload["latitude"]
    longitude = payload["longitude"]    

    verify_token(token) do
      id = @signed_in[token]
      verify_user(id, password) do
        @db.update_location(id, {latitude: latitude, longitude: longitude})
        {:message => "Location saved!"}.to_json
      end
    end
    
  end

  post '/withdraw' do
    payload = JSON.parse(request.body.read)
    token = payload["token"]
    password = payload["password"]
    withdraw_address = payload["withdrawAddress"]
    amount = payload["amount"]
    

    verify_token(token) do
      id = @signed_in[token]
      verify_user(id, password) do
        {:message => "#{amount} Ð was sent from your account to #{withdraw_address}"}.to_json
      end
    end

  end

  def km_between(coord, coord2)
    Geocoder::Calculations.distance_between(
      [coord[:latitude], coord[:longitude]],
      [coord2[:latitude], coord2[:longitude]]
    )
  end

  def nearby_users(id, center, radius)
    @db.get_users_locations.select do |user_location|
      km_between(center, user_location) < radius && user_location[:id] != id
    end
  end

  post '/rain' do
    payload = JSON.parse(request.body.read)

    token = payload["token"]
    password = payload["password"]
    amount = payload["amount"]
    radius = payload["radius"]
    

    verify_token(token) do
      id = @signed_in[token]
      verify_user(id, password) do
        user = @db.get_user(id)
        users = nearby_users(id, {latitude: user[:latitude], longitude: user[:longitude]}, radius)
        log = "You made it rain #{amount} Ð on #{users.count} shibes in a #{radius} km radius around your saved location #{user[:latitude]} lat, #{user[:longitude]} long"
        #TODO: insert rain logs for every selected user        
        {:message => log}.to_json
      end
    end
    
  end

  post '/bowl' do
    payload = JSON.parse(request.body.read)

    token = payload["token"]
    password = payload["password"]
    bowl_amount = payload["bowlAmount"]
    bite_amount = payload["biteAmount"]
    

    verify_token(token) do
      id = @signed_in[token]
      verify_user(id, password) do
        {:message => "Here is your new bowl code: 0x123456. Total of #{bowl_amount/bite_amount} bites at #{bite_amount} Ð a piece"}.to_json
      end
    end
    
  end

  post '/bite' do
    payload = JSON.parse(request.body.read)
    bowl_code = payload["bowlCode"]
    token = payload["token"]

    verify_token(token) do
      {:message => "You got a bite of 20 Ð!"}.to_json
    end
  end

  get '/rainlogs' do
    token = params["token"]    

    verify_token(token) do
      id = @signed_in[token]
      {rainLogs: @db.get_rain_logs(id).to_a}.to_json
    end
  end

  get '/bowls' do
    token = params["token"]    
    
    verify_token(token) do
      id = @signed_in[token]
      {bowls: @db.get_bowls(id).to_a}.to_json
    end
  end

  not_found do
    'Oh no! Something went wrong!'
  end
  
end
