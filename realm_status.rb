get '/realm/:realm' do
  content_type "text/plain"

  require 'open-uri'
  require 'xmlsimple'

  status_page = "http://www.worldofwarcraft.com/realmstatus/status.xml"
  realm = params[:realm]

  xml_data = XmlSimple.xml_in(open(status_page))
  status = xml_data["rs"].first["r"].select {|r| r["n"] == realm.capitalize }.first["s"] rescue "error"

  if status == "1"
    "up"
  elsif status == "error"
    record_hit
    "error"
  else
    "down"
  end
end
