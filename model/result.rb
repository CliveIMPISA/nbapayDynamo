require 'aws-sdk'
require 'json'

class Result < AWS::Record::HashModel
  string_attr :teamname
  string_attr :scraped
  timestamps

  def self.destroy(id)
    find(id).delete
  end

  def self.delete_all
    all.each { |r| r.delete }
  end
end
