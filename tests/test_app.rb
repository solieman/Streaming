ENV['RACK_ENV'] = 'test'

require './bin/app.rb'
require 'test/unit'
require 'rack/test'

class TicTacToeTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_that_server_responed
    get '/'
    assert last_response.ok?
  end


  def test_it_return_list_of_players
    get '/allplayers'
    assert last_response.body.include?(['Simon','John'])
    assert last_response.ok?

  end

  def test_it_says_hello_to_a_person
    get '/', :name => 'Simon'
    assert last_response.body.include?('Simon')
  end
end
