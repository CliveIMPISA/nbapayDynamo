require 'sinatra/base'
require 'sinatra'
require 'json'
require_relative 'model/single'
require_relative 'model/double'
require_relative 'model/result'
require_relative 'helpers.rb'
require 'httparty'

# nbasalaryscrape service
class NbaPayDynamo < Sinatra::Base

  configure :production, :development do
    enable :logging
  end

  configure :development do
    set :session_secret, "something"    # ignore if not using shotgun in development
  end

  helpers do
    include Helpers
  end


  delete '/api/v1/comparisons/:id' do
    begin
      Double.destroy(params[:id])
    rescue
      halt 404
    end
  end

  post '/api/v1/comparisons' do
    content_type :json
    body = request.body.read
    logger.info body

    begin
      req = JSON.parse(body)
      logger.info req
    rescue Exception => e
      puts e.message
      halt 400
    end
    double = Double.new
    double.teamname = req['teamname']
    double.playername1 = req['playername1']
    double.playername2 = req['playername2']

    if double.save
      redirect "/api/v1/comparisons/#{double.id}"
    end
  end

  get '/api/v1/comparisons/:id' do
    content_type :json
    logger.info "GET /api/v1/comparisons/#{params[:id]}"
    begin
      @double = Double.find(params[:id])
      teamname = @double.teamname
      playername1 = @double.playername1
      playername2 = @double.playername2
      players = [playername1, playername2]

    rescue
      halt 400
    end

    result = two_players_salary_data(teamname, players).to_json
    logger.info "result: #{result}\n"
    if result.nil? || result.empty?
      halt 404
    else

      result
    end
    result
  end

  delete '/api/v1/playertotal/:id' do
    single = Single.destroy(params[:id])
  end

  delete '/api/v1/result/:id' do
    single = Single.destroy(params[:id])
  end

  post '/api/v1/playertotal' do
    content_type :json
    body = request.body.read
    logger.info body

    begin
      req = JSON.parse(body)
      logger.info req
    rescue Exception => e
      puts e.message
      halt 400
    end
    single = Single.new
    single.teamname = req['teamname']
    single.playername1 = req['playername1']

    if single.save
      redirect "/api/v1/playertotal/#{single.id}"
    end
  end

  get '/api/v1/playertotal/:id' do
    content_type :json
    logger.info "GET /api/v1/playertotal/#{params[:id]}"
    begin
      @total = Single.find(params[:id])
      teamname = @total.teamname
      playername1 = [@total.playername1]
      results = Result.find(teamname)
      result = results.scraped

    rescue
      halt 400
    end

    result = player_total_salary(teamname, playername1).to_json
    logger.info "result: #{result}\n"
    result
  end

  get '/api/v1/:teamname.json' do
      content_type :json
      get_team(params[:teamname]).to_json

  end

  get '/api/v1/allteams' do
    all_teams.to_json
  end

  get '/api/v1/players/:teamname.json' do
    content_type :json
    get_team_players(params[:teamname]).to_json
  end

  post '/api/v1/check' do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
    rescue
      halt 400
    end
    teamname = req['teamname']
    playername1 = req['playername1']
    playername2 = req['playername2']
    players = [playername1, playername2]
    player_salary_data(teamname, players).to_json
  end

  post '/api/v1/check2' do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
    rescue
      halt 400
    end
    teamname = req['teamname']
    playername1 = req['playername1']
    playername2 = req['playername2']
    players = [playername1, playername2]
    player_total_salary(teamname, players).to_json
  end

  get '/' do
    'NBA PAY Service api/v1 is up and working at /api/v1/'
  end

  not_found do
    status 404
    'not found'
  end

  get '/api/v1/single/?' do
    content_type :json
    body = request.body.read

    begin
      index = Single.all.map do |t|
        { id: t.id, description: t.description,
          created_at: t.created_at, updated_at: t.updated_at }
      end
    rescue => e
        halt 400
    end

      index.to_json
  end
  get '/api/v1/double/?' do
    content_type :json
    body = request.body.read

    begin
      index = Double.all.map do |t|
        { id: t.id, description: t.description,
          created_at: t.created_at, updated_at: t.updated_at }
        end
      rescue => e
        halt 400
      end

      index.to_json
    end
    get '/api/v1/result/?' do
      content_type :json
      body = request.body.read

      begin
        index = Result.all.map do |t|
          { id: t.id, scraped: t.scraped,
            created_at: t.created_at, updated_at: t.updated_at }
          end
        rescue => e
          halt 400
        end

        index.to_json
      end

      get '/api/v1/populateresults' do
        puts "Good"
        content_type :json
        body = request.body.read
        begin
          puts "Good"
          allteams = all_teams.to_json
          # puts saved_results
          # if saved_results.nil? || saved_results.empty?
          #   allteams = HTTParty.get api_url('allteams')
          allteams.each do |team|
            populate = Result.new
            populate.teamname = team
            populate.scraped = get_team(team).to_json
            populate.save

          end
          # end
        rescue
          halt 400
        end
      end


      get '/api/v1/result/:id' do
        content_type :json
        logger.info "GET /api/v1/result/#{params[:id]}"
        begin
          @total = Result.find(params[:id])
          @total.scraped = "list"
          @total.save
        rescue
          halt 400
        end

      end

end
