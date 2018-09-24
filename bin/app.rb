require 'sinatra'
require 'sinatra/partial'
require 'thin'
require 'sinatra/base'
require 'securerandom'

require "./lib/room"
require "./lib/db"
# To require all files in specific directory
# Dir["./lib/*.rb"].each {|file| require file }

enable :sessions

set :port, 8080
set :static, true
set :public_folder, "static"
set :views, "views"

rooms = []
connections = []
allMessages = []
allPlayers = []

before do   # Before every request, make sure they get assigned an ID.
  session[:id] ||= SecureRandom.uuid
  allPlayers.push(session[:id])
end

get '/' do
  # erb :home, :locals => {'rooms' => rooms}
  # to load html page from the public/static folder
  send_file File.join(settings.public_folder, 'index.html')
end

post '/updateBoard' do
    lastPlayData = params
    targetRoom = nil

    rooms.each do |room|
      if room.xPlayer == session[:id] || room.oPlayer == session[:id]
        targetRoom = room
      else

      end
    end

    # targetRoom = rooms.detect { |r| r.xPlayer == session[:id]}

    # Streaming
    connections.each do |out|
      # notify client that a new message has arrived
      out << targetRoom.board.data

      # indicate client to connect again
      out.close
    end

    redirect '/'
end

get '/rooms' do

  puts 'rooms : getDB'
  roomsFromDB = []
  getDB.each do |oneRoom|
    unless oneRoom[:dead]
      tempRoom = Room.new(oneRoom[:id])
      tempRoom.xPlayer = oneRoom[:xPlayer]
      tempRoom.oPlayer = oneRoom[:oPlayer]
      tempRoom.board = Board.new(oneRoom[:board])
      roomsFromDB.push(tempRoom)
    end
  end

  roomsFromDB.map { |e| e.as_json }

  # Send the data as json to the client to display it
  content_type :json
  # { :rooms => rooms, :players => 'value2' }.to_json
  { :rooms => roomsFromDB }.to_json
end

post '/newRoom/' do

  rId = SecureRandom.uuid
  room = Room.new(rId)
  room.dead = false
  room.xPlayer = session[:id]
  room.oPlayer = params[:oPlayer]
  # rooms.push({ roomId:rId, xPlayer:session[:id], oPlayer:nil})
  rooms.push(room)

  newData(rId, room.as_json)

  # Streaming
  connections.each do |out|
    # notify client with the new created room ID

    content_type :json
    out << {:rId => rId}.to_json

    # indicate client to connect again
    out.close
  end

  redirect '/'
end

post '/roomData/' do
  content_type :json
  {:data => checkData(params[:id])}.to_json
end

post('/removeRoom/') do
  removeRoom(params[:id])
  redirect '/'
end

post '/join/' do
  # Check availble rooms
  # if we have room check the next
  if rooms.length > 0
    rooms.each do |room|
      if room.oPlayer !=nil
        # if the room have two players, check the next
        if room.xPlayer != session[:id]
          # create new room and insert the user as xPlayer
          redirect '/newRoom'
        end
          # Show the board
        break
      else
        # if room have only one player, add the player to it as oPlayer
        room.oPlayer = session[:id]
        break
      end
    end
  else
    # if we do not have any rooms, create new room and set xPlayer
    redirect '/newRoom'
  end
end

get '/myId' do
  session[:id]
end

get '/allplayers' do
  content_type :json
  {:data => allPlayers.uniq}.to_json
end

# for streaming check Streaming Responses in Sinatra documentation

# coding: utf-8
set server: 'thin', connections: []

get '/subscribe' do
  # register a client's interest in server events
  stream(:keep_open) do |out|
    connections << out
    # purge dead connections
    connections.reject!(&:closed?)
  end
end

post '/message' do
  allMessages.push({:message => params['data'], :sender => session[:id]})
  connections.each do |out|
    # notify client that a new message has arrived
    out << params['data'] << "\n"

    # indicate client to connect again
    out.close
  end

  # acknowledge
  "message received"
end

get '/allAvailableMessages' do
  # allMessages
  content_type :json
  {:data => allMessages}.to_json
end

# to delay...
get '/waitOtherPlayer' do
  sleep 1
  stream(:keep_open) do |out|
    connections << out
    # purge dead connections
    connections.reject!(&:closed?)
  end
end
