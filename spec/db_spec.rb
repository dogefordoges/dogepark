require './database'

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
      
      result = @db.query "select column_name, data_type from INFORMATION_SCHEMA.COLUMNS where table_name = 'users'"
      expect(result)
      expect(result[:id])
      expect(result[:name])
      expect(result[:password])
      expect(result[:latitude])
      expect(result[:longitude])
      expect(result[:public_key])
      expect(result[:private_key])
    end

    it "inserts a new user" do
      @db.insert_user({name: "hello", password: "world", public_key: "foo", private_key: "bar"})
    end

    it "gets user information" do
      user = @db.get_user("hello")
      expect(user[:id])
      expect(user[:name]).to eq "hello"
      expect(user[:password]).to eq "world"
      expect(user[:latitude]).to eq 0
      expect(user[:longitude]).to eq 0
      expect(user[:public_key])
      expect(user[:private_key])
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
      user = @db.get_user("hello")
      @db.insert_bowl({user_id: user[:id], code: "foo", total: 100, bite_size: 10})
    end

    it "gets bowls" do
      user = @db.get_user("hello")
      bowls = @db.get_bowls(user[:id])
      
      expect(bowls.count > 0)

      bowl = bowls.first
      expect(bowl[:id])
      expect(bowl[:user_id]).to eq user[:id]
      expect(bowl[:code]).to eq "foo"
      expect(bowl[:total]).to eq 100
      expect(bowl[:bite_size]).to eq 10
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

    it "inserts a rain log" do
      user = @db.get_user("hello")
      @db.insert_rain_log({user_id: user[:id], log: "foo"})
    end

    it "gets rain logs" do
      user = @db.get_user("hello")
      logs = @db.get_rain_logs(user[:id])

      expect(logs.count > 0)

      log = logs.first
      expect(log[:id])
      expect(log[:user_id]).to eq user[:id]
      expect(log[:log]).to eq "foo"
    end
    
  end

end
