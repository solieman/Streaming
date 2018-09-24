require 'securerandom'


class Player

    def initialize()
        @id = SecureRandom.uuid,
        @sign = "x" # or "o"
    end

    attr_reader :id
    attr_reader :sign

end
