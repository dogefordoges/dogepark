require 'sinatra'

get '/' do
  erb :index
end

get '/dogepark' do
  erb :dogepark
end
