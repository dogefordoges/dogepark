require 'sequel'

class Database

  def initialize
    @db = Sequel.connect(adapter: :postgres, database: 'dogepark')
  end

  def create_users
    @db.create_table :users do
      primary_key :id
      String :name, null: false
      String :password, null: false
      Float :latitude, default: 0
      Float :longitude, default: 0
      String :public_key, null: false
      String :private_key, null: false
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

  def create_bowls
    @db.create_table :bowls do
      primary_key :id
      String code
      Float total
      Float bite_size
    end
  end

  def drop_bowls
    @db.run("drop table bowls")
  end

  def insert_bowl(bowl)
    @db[:bowls].insert(bowl)
  end

  def get_bowls(code)
    @db[:bowls].all
  end

  def create_rain_logs(user)
    @db.create_table :rain_logs do
      primary_key :id
      String :log
    end
  end

  def drop_rain_logs
    @db.run("drop table rain_logs")
  end

  def insert_rain_log(log)
    @db[:rain_logs].insert(log)
  end

  def get_rain_logs(user)
    @db[:rain_logs].all
  end

  def query(query)
    @db[query]
  end
  
end
