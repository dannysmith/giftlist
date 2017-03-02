require 'sinatra'
require 'pry'
require 'mongoid'
require 'dotenv'
require './models/item'
require './models/user'
require './models/contact'

# Load Environment Variables
Dotenv.load!

# Load MongoDb
Mongoid.load! "mongoid.yml"
Mongoid.raise_not_found_error = false

# Rack Plugins
use Rack::MethodOverride
use Rack::Session::Cookie, key: '_rack_session',
                           path: '/',
                           expire_after: 2_592_000, # In seconds
                           secret: 't/ePKm+SRpuzLZIi3LeOl6wvmpkT6R18zKb7V8X2Vrz6BKOSjRSlkjyFtRoU983UUxFx6CX5EHTTAxiIVyLHRI2Ozo2kz5e8n4q934ofnr4pCXbSafbQBElRQxz4SzaMluvNj+Dx0TliMnYPTPDRjOKJZglTJkDTxQVR0S9C00OMk3ZwDoqwS0eqAJsX9BTiUTaiMtozdEPsWdV0HIZ1aUE/aHl3Aeknh1/A+s+AEMohYqtdtp6Wx7yjClz5TVzli8jYG/git/Q='

helpers do
  def current_user
    User.find_by_username session[:username]
  end

  def base_url
    ENV['BASE_URL']
  end

  def logged_in?
    if session[:username]
      true
    else
      false
    end
  end

  def authenticate!
    redirect '/login' unless logged_in?
  end
end

# Repont to all OPTIONS HTTP Requests with these headers
options '/*' do
  headers['Access-Control-Allow-Origin'] = "*"
  headers['Access-Control-Allow-Methods'] = "GET, POST, PUT, DELETE, OPTIONS"
  headers['Access-Control-Allow-Headers'] ="accept, authorization, origin"
end


get '/' do
  authenticate!
  @user = current_user
  @escaped_username = CGI.escape(@user.username)
  @escaped_base_url = CGI.escape(base_url)
  erb :index
end

#---------------- Login routes ----------------#

get '/login' do
  redirect '/' if logged_in?
  erb :login_form
end

post '/login' do
  user = User.find_by email: params[:email]

  if (user && user.password == params[:password])
    session[:username] = user.username
    redirect '/'
  else
    redirect '/login'
  end
end

get '/logout' do
  session[:username] = nil
  redirect '/login'
end

get '/register' do
  redirect '/' if logged_in?
  erb :register
end

post '/register' do
  user = User.find_by email: params[:email]
  if user
    puts "Duplicate registration"
    redirect '/login'
  else
    user = User.create! params
    session[:username] = user.username
    redirect '/'
  end
end

#---------------- Item routes ----------------#

# Recieves POST request from browser bookmarklet
post '/item' do
  request.body.rewind
  item = JSON.parse request.body.read
  user = User.find_by_username(item['username'])
  if user
    user.items.create! title: item['title'], url: item['url'], image_url: item['image_url']
  else
    status 404
  end
end

delete '/item/:id' do
  authenticate!
  Item.find(id: params[:id]).destroy
  redirect '/'
end

#---------------- Contact routes ----------------#

post '/contact' do
  authenticate!
  current_user.contacts.create! email: params[:email]
  redirect '/'
end

delete '/contact/:id' do
  authenticate!
  Contact.find(id: params[:id]).destroy
  redirect '/'
end
