require './database'

RSpec.describe Database, "Dogepark Postgres DB Unit Tests" do
  
  before(:all) do
    @db = Database.new
  end

  after(:all) do
    @db.drop_users
    #@db.drop_bowls
    #@db.drop_rain_logs
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
      expect(user[:name]).to eq "hello"
      expect(user[:password]).to eq "world"
      expect(user[:latitude]).to eq 0
      expect(user[:longitude]).to eq 0
      expect(user[:public_key])
      expect(user[:private_key])
    end
    
  end

  # context 'creates bowls table and inserts a new bowl' do

  #   it "creates bowls table" do
  #     result = @db.run("select column_name, data_type from INFORMATION_SCHEMA.COLUMNS where table_name = 'bowls'")
  #     expect(result)
  #   end

  #   it "inserts a bowl" do
      
  #   end

  #   it "gets bowls" do
  #   end
    
  # end

  # context 'creates rain logs table' do

  #   it "creates rain_logs tables" do
  #     result = @db.run("select column_name, data_type from INFORMATION_SCHEMA.COLUMNS where table_name = 'bowls'")
  #     expect(result)      
  #   end

  #   it "inserts a rain log" do
  #   end

  #   it "gets rain logs" do
  #   end
    
  # end

end
