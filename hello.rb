#!/usr/bin/env ruby

require 'csv'

require 'rubygems'
  require 'sinatra'
  require 'dm-core'
  require 'dm-timestamps'

require 'models/hit'

# set up Sinatra
configure do
  set :root, File.dirname(__FILE__)
  disable :static

  DataMapper.setup(:default, ENV['DATABASE_URL'] || 'sqlite3:development.db')
  DataMapper.auto_upgrade!

  Hit.auto_upgrade!
end

# show the environment information
get '/env' do
  content_type 'text/plain'
  require 'pp'
  # DATABASE_URL contains database login info
  ENV.reject {|k,v| k=="DATABASE_URL"}.pretty_inspect
end

# alias for the hits file
get '/hits' do
  redirect '/hits.csv'
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

  ip = request.env['REMOTE_ADDR'].split(",").first
  url = params[:splat].first || "(blank)"

  Hit.new(:ip => ip, :url => url).save

  ip
end
