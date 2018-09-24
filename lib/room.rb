require_relative 'board'

class Room

    def initialize(rId)
      # room Id
      @id = rId
      # room dead status will change to true when players finished playing
      @dead = false
      # xPlayer Id
      @xPlayer = nil
      # oPlayer Id
      @oPlayer = nil
      # room's board Id
      @board = Board.new()
    end

    attr_reader :id
    attr_accessor :dead
    attr_accessor :xPlayer
    attr_accessor :oPlayer
    attr_accessor :board


    def as_json(options={})
        {
            id: @id,
            dead: @dead,
            xPlayer: @xPlayer,
            oPlayer: @oPlayer,
            board: @board.data
        }
    end

    def to_json(*options)
        as_json(*options).to_json(*options)
    end

    def join(newPlayer)
      if @oPlayer == nil
        @oPlayer = newPlayer
      end
    end

end
