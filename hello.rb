require 'rubygems'
  require 'sinatra'
  require 'dm-core'
  require 'dm-timestamps'

require 'csv'

configure do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:development.db')
  DataMapper.auto_upgrade!
end

set :root, File.dirname(__FILE__)
disable :static

# show the environment information
get '/env' do
  content_type 'text/plain'
  require 'pp'
  ENV.pretty_inspect
end

get '/hits' do
  redirect '/hits.csv'
end

get '/hits.csv' do
  content_type "text/csv"

  data = Hit.all.map do |hit|
    [hit.ip, hit.url, hit.created_at.strftime]
  end

  report = StringIO.new
  CSV::Writer.generate(report, ',') do |csv|
    csv << ['IP','URL','DATE']
    data.each do |d|
      csv << d
    end
  end

  report.rewind
  report.readlines
end

get 'favicon.ico' do
  halt 403
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

Hit.auto_migrate!
