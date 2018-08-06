# coding: utf-8
require 'net/http'
require 'json'

def post(uri, json_data)
  req = Net::HTTP::Post.new(uri, 'Content-Type' => 'application/json')
  req.body = json_data.to_json 
  http = Net::HTTP.new(uri.host, uri.port)
  http.request(req).body
end

RSpec.describe Net::HTTP, "Dogepark Server Tests" do
  
  before(:example) do
    @base = "http://localhost:4567"
    @address = "0x123212321232123212324567"
  end
  
  context "Sign up/Sign in" do
    it "creates a new user" do
      uri = URI(@base + "/signup?username=hello&password=world")
      Net::HTTP.get(uri)
    end

    it "logs in as user" do
      uri = URI(@base + "/signin?username=hello&password=world")
      Net::HTTP.get(uri)
    end
  end

  context "Dogepark interaction" do
    
    it "gets balance" do
      uri = URI(@base + "/balance?address=" + @address)
      response = JSON.parse(Net::HTTP.get(uri))
      expect(response.has_key? "balance").to eq true
    end

    it "posts location" do
      uri = URI(@base + "/location")
      payload = {username: "hello", password: "world", latitude: "0.0", longitude: "0.0"}
      expected_response = {"message" => "Location saved!"}
      expect(JSON.parse(post uri, payload)).to eq expected_response
    end

    it "posts withdraw" do
      uri = URI(@base + "/withdraw")
      payload = {username: "hello", password: "world", address: @address, withdrawAddress: "0x1234567781223", amount: 100}
      expected_response = {"message" => "100 Ð was sent from your account to 0x1234567781223"}
      expect(JSON.parse(post uri, payload)).to eq expected_response
    end

    it "posts rain" do
      uri = URI(@base + "/rain")
      payload = {username: "hello", password: "world", address: @address, latitude: 0.0, longitude: 0.0, amount: 100, radius: 10}
      expected_response = {"message" => "You made it rain 100 Ð on 20 shibes in a 10 km radius around coordinate 0.0 lat, 0.0 long"}
      expect(JSON.parse(post uri, payload)).to eq expected_response
    end

    it "posts bowl" do
      uri = URI(@base + "/bowl")
      payload = {username: "hello", password: "world", address: @address, bowlAmount: 100, biteAmount: 1}
      expected_response = {"message" => "Here is your new bowl code: 0x123456. Total of 100 bites at 1 Ð a piece"}
      expect(JSON.parse(post uri, payload)).to eq expected_response
    end

    it "posts bite" do
      uri = URI(@base + "/bite")
      payload = {address: @address, bowlCode: "0x123456"}
      expected_response = {"message" => "You got a bite of 20 Ð!"}
      expect(JSON.parse(post uri, payload)).to eq expected_response
    end

    it "gets rain logs" do
      uri = URI(@base + "/rainlogs")
      response = JSON.parse(Net::HTTP.get(uri))
      expect(response.has_key? "rainLogs").to eq true
      expect(response["rainLogs"].class).to eq Array
    end
  end
end
