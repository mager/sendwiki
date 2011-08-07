MongoMapper.connection = Mongo::Connection.new('staff.mongohq.com', 10092)
MongoMapper.database = 'sendwiki'
MongoMapper.database.authenticate(ENV['MONGO_USER'], ENV['MONGO_PASSWORD'])

class Article
  include MongoMapper::Document
  key :article, String
  key :email, String

  timestamps!
end

