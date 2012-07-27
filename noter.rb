require 'sinatra'
require 'gon-sinatra'

require 'sass'

require 'coffee-script'
require 'json'

require 'mongoid'


# models
Dir.glob('./models/*.rb').each {|file| require_relative file }

Sinatra::register Gon::Sinatra

enable :sessions

configure do
  Mongoid.configure do |config|
    name = 'noter'
    host = 'localhost'
    config.master = Mongo::Connection.new.db(name)
    config.persist_in_safe_mode = false
  end
end

get '/' do
  #if session[:pass]
    #bucket = Pass.where(pass: session[:pass]).first.buckets.first.bucket
    #gon.bucket = bucket
    #gon.message = "Authorized, and notes loaded."
  #else
    #gon.bucket = ""
    #gon.message = "You have not authorized yet."
  #end
  erb :index
end

get '/notes' do
  content_type :json
  Pass.first.notes.to_a.to_json
end

post '/db' do
  if session[:pass]
    s = params[:data]
    bucket = Pass.where(pass: session[:pass]).first.buckets.first
    bucket.bucket = s
    if bucket.save
      status 200
    else
      status 500
    end
  else
    status 400
  end
end

get '/user' do
  Pass.create(pass: params[:pass])
  redirect to('/')
end

post '/authorize' do
  pass = Pass.where(pass: params[:pass]).first
  pass_string =  pass ? pass.pass : nil
  if pass_string
    session[:pass] = pass_string
    
    b = pass.buckets.first
    if b
      gon.bucket = pass.buckets.first.bucket
      gon.message = "Pass found. Authorized. Used existing bucket."
    else
      pass.buckets.create(bucket: "")
      gon.message = "Pass found. Authorized. Created empty bucket."
    end
    

  else
    gon.message = "Pass not found."
  end
  redirect to('/')
end

get '/deauthorize' do
  if session[:pass]
    session[:pass] = nil
    gon.message = "Deauthorized."
  end
  redirect to('/')
end



# any asset routes
get '/stylesheets/:name.css' do |n|
  scss :"stylesheets/#{n}", :views => 'public'
end

get %r{(.+)\.js\z} do |c|
  url_array = c.split('/')
  file_name = url_array.last
  coffee :"javascripts/#{file_name}", :views => 'public'
end
