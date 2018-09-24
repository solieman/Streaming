
def getDB
  # Dir['static/db/*.json'].map : Getting all the *.json files in the folder and map it to the next function
  # |f| JSON.parse File.read(f) : Read the file and parse its data as JSON
  # , :symbolize_names => true : ensure returning the data ready to be used as hashes
  # .flatten : return a one-dimensional flattening of this array
  json = Dir['static/db/*.json'].map { |f| JSON.parse File.read(f), :symbolize_names => true }.flatten
end

def newData(rId, roomJSON)
  # Local storage for the rooms
  File.open("static/db/#{rId}.json","w") do |f|
    f.write(JSON.pretty_generate(roomJSON))
  end
end

def checkData(rId)
  # Local storage for the rooms
  File.open("static/db/#{rId}.json","r") do |f|
    JSON.parse File.read(f), :symbolize_names => true
  end
end

def removeRoom(rId)
  begin
    File.delete("static/db/#{rId}.json")
  rescue
    puts "File #{rId} not exist"
  end
end
