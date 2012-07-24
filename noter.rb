require 'sinatra'
require 'gon-sinatra'
require 'sass'
require './dropbox.rb'

Sinatra::register Gon::Sinatra

enable :sessions

APP_KEY = "znz3jip9v0sxfnb"
APP_SECRET = "n9yx3m803a75zi1"
ACCESS_TYPE = :dropbox

get '/' do
  if session[:dropbox_session]
    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized
    begin
      file = client.get_file("noter.txt")
      gon.dropboxInfo = file
    rescue
      client.put_file("noter.txt", File.open("noter.txt", "w+"))
    end
  else
    gon.dropboxInfo = ""
  end
  erb :index
end

get '/authorize' do
  if !params[:oauth_token]
    dbsession = DropboxSession.new(APP_KEY, APP_SECRET)
    session[:dropbox_session] = dbsession.serialize #serialize and save this DropboxSession
    #pass to get_authorize_url a callback url that will return the user here
    redirect to(dbsession.get_authorize_url(request.url))
  else
    # the user has returned from Dropbox
    dbsession = DropboxSession.deserialize(session[:dropbox_session])
    dbsession.get_access_token  #we've been authorized, so now request an access_token
    session[:dropbox_session] = dbsession.serialize

    redirect to("/")
  end
end

get '/deauthorize' do
  if session[:dropbox_session]
    session[:dropbox_session] = nil
    redirect to("/")
  end
end

post '/dropbox' do
  if params[:data] && session[:dropbox_session]
    file = File.open("noter.txt", "w+")
    file.write params[:data]
    file.rewind
    upload(file)
  end
end


# any asset routes
get '/stylesheets/:name.css' do |n|
  scss :"stylesheets/#{n}", :views => 'public'
end



def upload(file)
  dbsession = DropboxSession.deserialize(session[:dropbox_session])
  client = DropboxClient.new(dbsession, ACCESS_TYPE) #raise an exception if session not authorized
  # upload the file to dropbox
  resp = client.put_file("noter.txt", file, true)

end

