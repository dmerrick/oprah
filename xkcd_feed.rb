# returns a modified version of the xkcd feed with the alt text separate
get '/xkcd.rss' do
  content_type 'application/rss+xml'

  require 'rss/2.0'
  require 'rss/maker'
  require 'open-uri'

  source = "http://xkcd.com/rss.xml"
  rss = RSS::Parser.parse(open(source).read, false)

  content = RSS::Maker.make("2.0") do |m|
    m.channel.title = rss.channel.title
    m.channel.link = rss.channel.link
    m.channel.description = rss.channel.description
    m.channel.date = rss.channel.date
    m.items.do_sort = true # sort items by date
  
    rss.items.each do |item|
      i = m.items.new_item
      i.title = item.title
      i.link = item.link
      i.date = item.date

      alt_text = item.description.sub(/.*alt=/,'').sub(/..>.*/,'')
      i.description = item.description + "<br />" + alt_text
    end

  end

  content.to_s
end
