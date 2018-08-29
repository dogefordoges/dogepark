# coding: utf-8
require 'net/http'
require 'json'
require './app/database'
require './app/location'

def post(uri, json_data)
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = json_data.to_json 
  http = Net::HTTP.new(uri.host, uri.port)
  http.request(req)
end

class Sequel::Dataset
  def to_a
    arr = []
    all.each do |x|
      arr << x
    end
  end
end

RSpec.describe Net::HTTP, "Dogepark Server Tests" do
  
  before(:all) do
    @base = "http://localhost:9292"
    @address = "0x123212321232123212324567"
    @db = Database.new
    @db.create_users
    @db.create_bowls
    @db.create_rain_logs
  end

  after(:all) do
    @db.drop_bowls
    @db.drop_rain_logs
    @db.drop_users
  end
  
  context "Sign up/Sign in" do
    it "posts new user" do
      uri = URI(@base + "/signup")
      payload = {username: "hello", password: "world"}
      expected_response = {"message" => "signed up", "url" => "none"}
      other_response = {"message" => "already signed up", "url" => "none"}
      response = post(uri, payload)
      body = JSON.parse(response.body)

      expect(response.code).to eq  "200"
      expect(body == expected_response || body == other_response).to eq true
    end

    it "posts incorrect username" do
      uri = URI(@base + "/signin")
      payload = {username: "hell0", password: "world"}
      post uri, payload
      expected_response = {"message" => "not signed up", "url" => "none"}
      response = post(uri, payload)
      body = JSON.parse(response.body)
      expect(response.code).to eq "200"
      expect(body).to eq expected_response      
    end    

    it "posts incorrect password" do
      uri = URI(@base + "/signin")
      payload = {username: "hello", password: "world!"}
      post uri, payload
      expected_response = {"message" => "password incorrect", "url" => "none"}
      response = post(uri, payload)
      body = JSON.parse(response.body)
      expect(response.code).to eq "200"
      expect(body).to eq expected_response      
    end

    it "posts signed in user" do
      uri = URI(@base + "/signin")
      payload = {username: "hello", password: "world"}
      response = post(uri, payload)
      body = JSON.parse(response.body)      
      expect(response.code).to eq "200"
      expect(body["message"]).to eq "welcome to dogepark!"
      $token = body["token"]
    end

    it "signs up/signs in second user" do
      post(URI(@base + "/signup"), {username: "fred", password: "frankiedoodle"})
      body = JSON.parse(post(URI(@base + "/signin"), {username: "fred", password: "frankiedoodle"}).body)
      $token2 = body["token"]
    end

  end

  context "Dogepark interaction" do
    
    it "gets balance" do
      uri = URI(@base + "/balance?token=" + $token)
      response = JSON.parse(Net::HTTP.get(uri))
      expect(response.has_key? "balance").to eq true
    end

    it "posts location" do
      uri = URI(@base + "/location")
      payload = {password: "world", latitude: "0.0", longitude: "0.0", token: $token}
      expected_response = {"message" => "Location saved!"}
      response = post(uri, payload)
      body = JSON.parse(response.body)      
      expect(response.code).to eq "200"
      expect(body).to eq expected_response

      # posts second user location
      post(uri, {password: "frankiedoodle", latitude: "0.0", longitude: "0.0", token: $token2})
    end

    it "posts withdraw" do
      uri = URI(@base + "/withdraw")
      payload = {password: "world", address: @address, withdrawAddress: "0x1234567781223", amount: 100, token: $token}
      expected_response = {"message" => "100 Ð was sent from your account to 0x1234567781223"}

      response = post(uri, payload)
      body = JSON.parse(response.body)      
      expect(response.code).to eq "200"
      expect(body).to eq expected_response      
    end

    it "gets nearby users" do
      locations = @db.get_users_locations.to_a

      expect(locations.class).to eq Array

      location = locations.first

      users = Location::nearby_users(locations, location[:id], {latitude: location[:latitude], longitude: location[:longitude]}, 10)

      expect(users.class).to eq Array

      user = users.first
      
      expect(user[:id])
      expect(user[:latitude])
      expect(user[:longitude])
    end

    it "posts rain" do
      uri = URI(@base + "/rain")
      payload = {password: "world", amount: 100, radius: 10, token: $token}
      expected_response = {"message" => "You made it rain 100 Ð on 1 shibes in a 10 km radius around your saved location 0.0 lat, 0.0 long"}

      response = post(uri, payload)
      body = JSON.parse(response.body)      
      expect(response.code).to eq "200"
      expect(body).to eq expected_response      
      
    end

    it "posts bowl" do
      uri = URI(@base + "/bowl")
      payload = {password: "world", id: @address, bowlAmount: 100, biteAmount: 1, token: $token}
      expected_response = {"message" => "Here is your new bowl code: 0x123456. Total of 100 bites at 1 Ð a piece"}

      response = post(uri, payload)
      body = JSON.parse(response.body)      
      expect(response.code).to eq "200"
      expect(body).to eq expected_response      
      
    end

    it "posts bite" do
      uri = URI(@base + "/bite")
      payload = {bowlCode: "0x123456", token: $token}
      expected_response = {"message" => "You got a bite of 20 Ð!"}

      response = post(uri, payload)
      body = JSON.parse(response.body)
      expect(response.code).to eq "200"
      expect(body).to eq expected_response      
            
    end

    it "gets rain logs" do
      uri = URI(@base + "/rainlogs?token=" + $token2)
      response = JSON.parse(Net::HTTP.get(uri))
      expect(response.has_key? "rainLogs").to eq true
      expect(response["rainLogs"].class).to eq Array
      expect(response["rainLogs"].length > 0).to eq true
      expect(response["rainLogs"].first.keys).to eq ["log"]
    end

    it "gets bowls" do
      uri = URI(@base + "/bowls?token=" + $token)
      response = JSON.parse(Net::HTTP.get(uri))
      expect(response.has_key? "bowls").to eq true
      expect(response["bowls"].class).to eq Array
      expect(response["bowls"].length > 0).to eq true
      bowl_data = response["bowls"].first      
      expect(bowl_data.keys).to eq ["code", "total", "bite_size"]
    end
  end
end
