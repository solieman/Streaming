require "./lib/room.rb"
require 'test/unit'
require 'rack/test'
require 'securerandom'

class TicTacToeTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def test_room_creation()
    room = Room.new('123')
    assert_equal('123', room.id)
  end

  def test_join_room()
    room = Room.new('123')
    room.join("new-player")
    assert_equal('new-player', room.oPlayer)
  end

  def test_get_board_data_from_room()
    room = Room.new()
    assert_equal([1,2,4,8,16,32,64,128,256], room.board.data)
  end
end
