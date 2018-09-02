require './app/database'

RSpec.describe Database, "Dogepark Postgres DB Unit Tests" do
  
  before(:all) do
    @db = Database.new
  end

  after(:all) do
    @db.drop_bowls
    @db.drop_rain_logs
    @db.drop_users
  end

  context 'creates a users table and inserts a user' do

    it "creates users table" do
      @db.create_users
      
      #result = @db.query "select column_name, data_type from INFORMATION_SCHEMA.COLUMNS where table_name = 'users'"
      #expect(result)
      #expect(result.first.keys).to eq [:id, :name, :password, :latitude, :longitude, :address, :public_key, :private_key]
    end

    it "inserts a new user" do
      @db.insert_user({name: "hello", password: "world", public_key: "foo", private_key: "bar"})
    end

    it "gets user information" do
      user = @db.get_user_by_name("hello")
      
      $id = user[:id]
      
      expect(user[:id])
      expect(user[:name]).to eq "hello"
      expect(user[:password]).to eq "world"
      expect(user[:latitude]).to eq 0
      expect(user[:longitude]).to eq 0
      expect(user[:public_key])
      expect(user[:private_key])
    end

    it "updates users location" do
      @db.update_location($id, {latitude: 42.42, longitude: 42.42})

      user = @db.get_user($id)
      expect(user[:latitude]).to eq 42.42
      expect(user[:longitude]).to eq 42.42
    end

    it "creates new user near old user" do
      @db.insert_user({name: "hezzo", password: "w0rld", public_key: "fooz", private_key: "barz", latitude: 43, longitude: 43})
    end

    it "gets all users locations" do
      user_locations = @db.get_users_locations
      loc = user_locations.first
      expect(loc[:id])
      expect(loc[:latitude])
      expect(loc[:longitude])
    end

    it "creates new user with address" do
      @db.insert_user({name: "fuzzy", password: "tacos", public_key: "fuzzy", private_key: "tacos", latitude: 0.0, longitude: 0.0, address: "Yellow Snickery"})
    end

    it "gets users at address" do
      users = @db.get_users_at_address "Yellow Snickery"
      expect(users.first)
      expect(users.first[:id])
    end

    it "gets user by public key" do
      user = @db.get_user_by_public_key("foo")
      expect(user[:name]).to eq "hello"
    end
    
  end

  context 'creates bowls table and inserts a new bowl' do

    it "creates bowls table" do
      @db.create_bowls
      
      result = @db.query "select column_name, data_type from INFORMATION_SCHEMA.COLUMNS where table_name = 'bowls'"
      expect(result)
      expect(result[:id])
      expect(result[:user_id])
      expect(result[:code])
      expect(result[:total])
      expect(result[:bite_size])
    end

    it "inserts a bowl" do
      user = @db.get_user($id)
      @db.insert_bowl({user_id: user[:id], code: "foo", total: 100, bite_size: 10})
    end

    it "gets bowls" do
      user = @db.get_user($id)
      bowls = @db.get_bowls(user[:id])
      
      expect(bowls.count > 0)

      bowl = bowls.first
      expect(bowl[:code]).to eq "foo"
      expect(bowl[:total]).to eq 100
      expect(bowl[:bite_size]).to eq 10
      expect(bowl.keys).to eq [:code, :total, :bite_size]
    end
    
  end

  context 'creates rain logs table' do

    it "creates rain_logs tables" do
      @db.create_rain_logs
      
      result = @db.query "select column_name, data_type from INFORMATION_SCHEMA.COLUMNS where table_name = 'rain_logs'"
      expect(result)
      expect(result[:id])
      expect(result[:user_id])
      expect(result[:log])
    end

    it "inserts a rain log without address" do
      user = @db.get_user($id)
      @db.insert_rain_log({user_id: user[:id], amount: 100, shibe_count: 42, radius: 10, latitude: 0.0, longitude: 0.0, using_address: false})
    end

    it "inserts a rain log with address" do
      user = @db.get_user($id)
      @db.insert_rain_log({user_id: user[:id], amount: 100, shibe_count: 42, radius: 10, latitude: 0.0, longitude: 0.0, address: "Yellow Snickery", using_address: true})
    end

    it "gets rain logs" do
      user = @db.get_user($id)
      logs = @db.get_rain_logs(user[:id])

      expect(logs.count > 0)

      log = logs.first
      expect(log[:amount]).to eq 100
      expect(log.keys).to eq [:id, :user_id, :amount, :shibe_count, :radius,:latitude, :longitude, :address, :using_address]
    end
    
  end

end
