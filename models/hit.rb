class Hit
  include DataMapper::Resource

  property :id, Serial

  property :url, String
  property :ip, String

  property :created_at, DateTime

end
