require 'rubygems'
  require 'sinatra'
  require 'dm-core'
  require 'dm-timestamps'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://my.db')
#DataMapper.auto_upgrade!

set :root, File.dirname(__FILE__)
disable :static

get '/hits' do
  Hit.all.map do |hit|
    hit.ip + ", " + hit.url
  end.join(",\n")
end

get '/?*' do
  content_type "text/plain"

  ip = request.env['REMOTE_ADDR'].split(",").first
  url = params[:splat].first
  url = "(blank)" if url.blank?

  Hit.new(:ip => ip, :url => url).save

  ip
end

class Hit
  include DataMapper::Resource

  property :id, Serial

  property :url, String
  property :ip, String

  property :created_at, DateTime

end

