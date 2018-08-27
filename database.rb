require 'sequel'

class Database

  def initialize
    @db = Sequel.connect(adapter: :postgres, database: 'dogepark')
  end

  def create_users
    @db.create_table :users do
      primary_key :id
      String :name, null: false, unique: true
      String :password, null: false
      Float :latitude, default: 0
      Float :longitude, default: 0
      String :public_key, null: false, unique: true
      String :private_key, null: false, unique: true
    end
  end

  def drop_users
    @db.run("drop table users")
  end

  def insert_user(user)
    @db[:users].insert(user)
  end

  def get_user(name)
    @db[:users].where(name: name).first
  end

  def update_location(name, location)
    @db[:users].where(name: name).update(location)
  end

  def get_users_locations
    @db[:users].select(:id, :latitude, :longitude)
  end

  def create_bowls
    @db.create_table :bowls do
      primary_key :id
      foreign_key :user_id, :users, unique: true
      String :code, null: false
      Float :total, null: false
      Float :bite_size, null: false
    end
  end

  def drop_bowls
    @db.run("drop table bowls")
  end

  def insert_bowl(bowl)
    @db[:bowls].insert(bowl)
  end

  def get_bowls(user_id)
    @db[:bowls].where(user_id: user_id)
  end

  def create_rain_logs
    @db.create_table :rain_logs do
      primary_key :id
      foreign_key :user_id, :users, unique: true
      String :log, null: false
    end
  end

  def drop_rain_logs
    @db.run("drop table rain_logs")
  end

  def insert_rain_log(log)
    @db[:rain_logs].insert(log)
  end

  def get_rain_logs(user_id)
    @db[:rain_logs].where(user_id: user_id)
  end

  #For testing
  def query(query)
    @db[query]
  end
  
end
