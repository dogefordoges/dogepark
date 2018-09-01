# Initialize environment for demo purposes

require './app/database'

db = Database.new

#db.drop_bowls
#db.drop_rain_logs
#db.drop_users

db.create_users
db.create_bowls
db.create_rain_logs

db.insert_user({name: "hello", password: "world", public_key: "bar", private_key: "foo"})
