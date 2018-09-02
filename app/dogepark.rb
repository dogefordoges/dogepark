# coding: utf-8
require 'sinatra'
require 'json'
require 'jwt'
require './app/database'
require './app/location'
require 'geocoder'

class Sequel::Dataset
  def to_a
    arr = []
    all.each do |x|
      arr << x
    end
  end
end

def ip_to_results(ip)
  results = Geocoder.search(ip)
  {coordinates: results.first.coordinates, address: results.first.address}
end

class DogeParkApp < Sinatra::Base

  def initialize
    super()

    @accounts = {}
    @hmac_secret = "foobar"
    @db = Database.new
    @signed_in = {} # maps JWT tokens to user id's
    @index = File.read(File.join('app/public', 'index.html'))
    
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
    @index
  end

  post '/signup' do
    payload = JSON.parse(request.body.read)
    username = payload['username']
    password = payload['password']
    if password && username
      user = @db.get_user_by_name(username)
      if user
        {:message => "already signed up"}.to_json
      else
        new_user(username, password)
        {:message => "signed up"}.to_json
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
          {:message => "password incorrect", :token => "403 Forbidden"}.to_json
        end
      else
        {:message => "not signed up", :token => "403 Forbidden"}.to_json
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

  get '/location' do
    ip = request.ip
    ip_to_results(ip).to_json
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
        body "Public key not found"
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
        {:amount => amount, :withdrawAddress => withdraw_address}.to_json
      end
    end

  end

  post '/rain' do
    payload = JSON.parse(request.body.read)

    token = payload["token"]
    password = payload["password"]
    amount = payload["amount"]
    radius = payload["radius"]
    address = payload["address"]
    using_address = payload["usingAddress"]# bool
    

    verify_token(token) do
      id = @signed_in[token]
      verify_user(id, password) do
        user = @db.get_user(id)

        if using_address
          users = @db.get_users_at_address(address)
        else        
          locations = @db.get_users_locations.to_a # Gets all user's locations
          users = Location::nearby_users(locations, id, {latitude: user[:latitude], longitude: user[:longitude]}, radius)
        end

        users.each do |user|
          @db.insert_rain_log({user_id: user[:id], amount: amount, shibe_count: users.count, radius: radius, latitude: user[:latitude], longitude: user[:longitude], address: address, using_address: using_address})
        end
        
        {:amount => amount, :numShibes => users.count, :radius => radius, :latitude => user[:latitude], :longitude => user[:longitude], address: address}.to_json                                                               
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
        @db.insert_bowl({user_id: id, code: "0x123456", total: bowl_amount, bite_size: bite_amount})
        {:code => "0x123456", :numBites => bowl_amount/bite_amount, :biteAmount => bite_amount}.to_json
      end
    end
    
  end

  post '/bite' do
    payload = JSON.parse(request.body.read)
    bowl_code = payload["bowlCode"]
    token = payload["token"]

    verify_token(token) do
      {:biteSize => 20}.to_json
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
