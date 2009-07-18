require 'rubygems'
  require 'sinatra'
  require 'dm-core'
  require 'dm-timestamps'

require 'csv'

DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3://my.db')
#DataMapper.auto_upgrade!

set :root, File.dirname(__FILE__)
disable :static

get '/hits' do
  content_type "text/plain"

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

get '/?*' do
  content_type "text/plain"

  ip = request.env['REMOTE_ADDR'].split(",").first
  url = params[:splat].first
  url = "(blank)" if url.blank?

  # there must be a better way to do this
  unless url == "favicon.ico"
    Hit.new(:ip => ip, :url => url).save
  end

  ip
end

class Hit
  include DataMapper::Resource

  property :id, Serial

  property :url, String
  property :ip, String

  property :created_at, DateTime

end

