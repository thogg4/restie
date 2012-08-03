require 'sinatra'
require 'sass'
require 'mongoid'



get '/' do
  # this is a fixed entry point
  'fixed entry point'
end

get '/items' do
  # this should render all of the items, or a subset of the items based on any params passed in through hypermedia
end

put '/items' do
  # this should replace the entire collection of items
end

post '/items' do
  # this should create and insert a new item into the collection
end

delete '/items' do
  # this should delete the entire collection
end





get '/item/:id' do
  # this should render one item. the one with the id from the URI
end

put '/item/:id' do
  # this should replace one item. the one with the id from the URI
end

post '/item/:id' do
  # this should 'create' a new item within the item. Yo Dawg.
end

delete '/item/:id' do
  # this should delete one item. the one with the id from the URI
end

