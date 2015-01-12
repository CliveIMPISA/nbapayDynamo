require 'aws-sdk'
require 'json'

class Double < AWS::Record::HashModel
  string_attr :teamname
  string_attr :playername1
  string_attr :playername2
  string_attr :description
  timestamps

  def self.destroy(id)
    find(id).delete
  end

  def self.delete_all
    all.each { |r| r.delete }
  end
end
