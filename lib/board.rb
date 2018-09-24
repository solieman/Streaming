class Board

    def initialize(initData = [1,2,4,8,16,32,64,128,256])
        @data = initData
    end

    attr_reader :data

    def update()
        puts "Updating the board data"
    end

end
