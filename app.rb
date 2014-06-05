require 'sinatra'

get '/' do
  # use the views/index.erb file
  erb :'index.html'
end
