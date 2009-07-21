#!/usr/bin/env ruby

require 'csv'
require 'pp'

require 'rubygems'
  require 'sinatra'
  require 'dm-core'
  require 'dm-timestamps'
  require 'net/ping'

require 'models/hit'

# set up Sinatra
configure do
  set :root, File.dirname(__FILE__)
  disable :static

  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:development.db')
  DataMapper.auto_upgrade!

  Hit.auto_upgrade!
end

helpers do
  def record_hit
    ip = request.env['REMOTE_ADDR'].split(",").first
    url = request.path_info || "(blank)"

    Hit.new(:ip => ip, :url => url).save
    
    return ip
  end
end

# bring in the xkcd feed route
require 'xkcd_feed'

get '/up/:host' do
  content_type 'text/plain'

  record_hit

  Net::PingExternal.new(params[:host]).ping.to_s
end

# show the environment information
get '/env' do
  content_type 'text/plain'

  record_hit

  # DATABASE_URL contains database login info
  ENV.reject {|k,v| k=="DATABASE_URL"}.pretty_inspect
end

# alias for the hits file
get '/hits' do
  record_hit
  redirect '/hits.csv'
end

# delete a hit with a given timestamp
get '/hit/:date' do
  date = DateTime.parse(params[:date]) rescue pass

  hit = Hit.all(:created_at => date)
  hit.destroy!
end

# auto-generate hits file
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

# keep browsers from looking for favicon
get 'favicon.ico' do
  halt 403
end

# show IP and log everything else
get '/?*' do
  content_type "text/plain"

  record_hit
end
