get '/torrents.rss' do
  content_type 'application/rss+xml'

  require 'rss/2.0'
  require 'rss/maker'
  require 'open-uri'
  
  feeds_list = "torrent_feeds.txt"
  sources = open(feeds_list).readlines

  content = RSS::Maker.make("2.0") do |m|
    m.channel.title = "Dana's TV Shows Feed!"
    m.channel.link = "http://tvrss.net"
    m.channel.description = "An amalgam of all of the shows I download."
    #m.channel.date = Time.now
    m.items.do_sort = true # sort items by date
  
    sources.each do |source|
      rss = RSS::Parser.parse(open(source).read, false)

      rss.items.each do |item|
        i = m.items.new_item
        i.title = item.title
        i.link = item.link
        i.date = item.date
        i.description = item.description
      end

    end
  end

  content.to_s
end
