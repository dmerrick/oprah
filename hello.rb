require 'rubygems'
  require 'sinatra'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://my.db')

get '/:url' do |url|
  content_type "text/plain"

  request.env['REMOTE_ADDR'].split(",").first
  url

  #Hit.new(:url => url).save
end

get '/hits' do
  Hit.all.each do |hit|
    hit.inspect
  end
end
