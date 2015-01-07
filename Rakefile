require './app'
require 'rake/testtask'
require_relative 'model/double.rb'
require_relative 'model/result.rb'
require_relative 'model/single.rb'

task :default => :spec

desc "Run all tests"
  Rake::TestTask.new(name=:spec) do |t|
  t.pattern = 'spec/*_spec.rb'
end

namespace :db do
  desc "Create database"
  task :migrate do
    begin
      Double.create_table(5, 6)
    rescue AWS::DynamoDB::Errors::ResourceInUseException => e
      puts 'DB exists -- no changes made, no retry attempted'
    end
  end
end
namespace :db do
  desc "Create database"
  task :migrate do
    begin
      Result.create_table(5, 6)
    rescue AWS::DynamoDB::Errors::ResourceInUseException => e
      puts 'DB exists -- no changes made, no retry attempted'
    end
  end
end
namespace :db do
  desc "Create database"
  task :migrate do
    begin
      Single.create_table(5, 6)
    rescue AWS::DynamoDB::Errors::ResourceInUseException => e
      puts 'DB exists -- no changes made, no retry attempted'
    end
  end
end
