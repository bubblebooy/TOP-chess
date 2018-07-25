require_relative "Chess_Pieces.rb"

class Player
  attr_reader :name
  attr_reader :computer
  attr_accessor :color
  def initialize(name, color = nil)
    @name = name
    @color = color
    @computer = (@name == "" || @name.downcase == "computer") ? true : false
  end

end


class Chess
  attr_reader :board
  attr_reader :whos_turn
  attr_reader :move_history
  def initialize(player_1,player_2)
    @players = [player_1,player_2]
    @whos_turn = player_1
    # next_turn unless [true,false].sample  ## this line randomises who is white
    @players[0].color = "white"
    @players[1].color = "black"
    @whos_turn = player_1
    @board = Array.new(8) { Array.new(8) }
    @captured  = []
    @move_history = []
    set_up_board
  end

  def next_turn
    @whos_turn = @players[(@players.index(@whos_turn)+1)%2]
    return @whos_turn
  end

  def set_up_board
    @board = Array.new(8) { Array.new(8)}
    King.new([7,3],"black",self)
    King.new([0,4],"white",self)
    Queen.new([7,4],"black",self)
    Queen.new([0,3],"white",self)
    Rook.new([7,0],"black",self)
    Rook.new([7,7],"black",self)
    Rook.new([0,0],"white",self)
    Rook.new([0,7],"white",self)
    Bishop.new([7,2],"black",self)
    Bishop.new([7,5],"black",self)
    Bishop.new([0,2],"white",self)
    Bishop.new([0,5],"white",self)
    Knight.new([7,1],"black",self)
    Knight.new([7,6],"black",self)
    Knight.new([0,1],"white",self)
    Knight.new([0,6],"white",self)
    8.times {|i| Pawn.new([6,i],"black",self)}
    8.times {|i| Pawn.new([1,i],"white",self)}

  end

  # def valid_position? ( position )
  #   position.each{ |i| return false unless i>=0 && i<8}
  #   return false unless @board[position[0]][position[1]].nil? # check if other player piece
  #   true
  # end

  def check(color = @whos_turn.color)
    king = nil
    @board.each do |row|
      row.each do |piece|
        king = piece if !piece.nil? && piece.color == color && piece.instance_of?(King)
        break unless king.nil?
      end
      break unless king.nil?
    end
    @board.each do |row|
      row.each do |piece|
        next if piece.nil? || piece.color == color
        piece.get_valid_moves
        return true if !piece.nil? && piece.valid_moves.include?(king.position)
        # king = position if !position.nil? && position.color == color && position.instance_of?(King)
      end
    end
    return false
  end

  def check_mate(color = @whos_turn.color)
    return "no check" unless check(color)
    game = Marshal::dump(self)
    @board.each_index do |row|
      @board[row].each_index do |column|
        next if @board[row][column].nil? || @board[row][column].color != color
        # puts @board[row][column].nil?
        @board[row][column].get_valid_moves
        @board[row][column].valid_moves.each do |test_move|
          test_game = Marshal::load(game)
          test_game.move([row,column],test_move)
          return false if test_game.check == false
          end
      end
    end
    true
  end

  def string_position_array(string)
    string = string.downcase.strip
    return "invalid" unless /^[a-h][1-8]$/ === string
    string = string.split(//)
    string[0] , string[1] = string[1].to_i-1 , ("a".."h").to_a.index(string[0])
    return string
  end


  def move(piece_position, destination)
    if piece_position.is_a? String
      position = string_position_array(piece_position)
      return "Piece position string is invalid" if  position == "invalid"
    else
      position = piece_position
    end
    if destination.is_a? String
      new_position = string_position_array(destination)
      return "Destination string is invalid" if  new_position == "invalid"
    else
      new_position = destination
    end
    piece = @board[position[0]][position[1]]
    return "There is no piece at #{piece_position}" if piece.nil?
    return "The #{piece.class.name} at #{piece_position} is not yours" if piece.color != @whos_turn.color
    return piece.castle(@board[new_position[0]][new_position[1]]) if piece.is_a? King and @board[new_position[0]][new_position[1]].is_a? Rook
    piece.get_valid_moves
    return "Invalid move: #{piece.class.name} at #{piece_position} can not move to #{destination}" unless piece.valid_moves.include?(new_position)
    captured = @board[new_position[0]][new_position[1]] #  unless @board[new_position[0]][new_position[1]].nil?
    @board[position[0]][position[1]] , @board[new_position[0]][new_position[1]] = nil , piece
    piece.position = new_position
    if check
      @board[position[0]][position[1]] , @board[new_position[0]][new_position[1]] = piece , captured
      piece.position = position
      return "Move put would put your king in check: #{piece.class.name} at #{piece_position} to #{destination}"
    end
    piece.moved = true
    @move_history << [position,new_position]
    if piece.is_a?(Pawn) && position[1] != new_position[1] && captured.nil?   #En passant
      captured = @board[position[0]][new_position[1]]                         #En passant
      @board[position[0]][new_position[1]] = nil                              #En passant
    end                                                                       #En passant
    @captured << captured unless captured.nil?
    piece.promote if piece.is_a?(Pawn) && (piece.position[0] == 0 || piece.position[0] == 7)

    return true

  end

  def print_board
    # chess_pieces = ["\u265A","\u265B","\u265C","\u265D","\u265E","\u265F"] #this is for testing
    # chess_pieces = ["\u2654","\u2655","\u2656","\u2657","\u2658","\u2659"]
    puts ""
    puts "enter move in the format of : piece-position destination"
    puts "exampes: 'g2 g3' or 'b8 to c6'"
    puts ""
    print "   "
    ('a'..'h').each { |j| print j.center(6) }
    puts ""
    background = true
    @board.to_enum.with_index.reverse_each do |row, i|
      3.times do |k|
        print k ==1 ? "#{i+1}: " : "   "
        row.each do |space|
          print background ? "\e[43m" : "\e[100m"
          print space.color == "black" ? "\e[30m" : "\e[97m" unless space.nil?
          # print  k == 1 ? chess_pieces.sample.center(6) : "      "
          print "#{(space.nil? || k != 1 ? "" : space.to_s )}".center(6) #space.to_s
          print "\e[0m"
          background = !background
        end
        print k ==1 ? "  :#{i+1} " : "     "
        print "#{@captured[i*3 + (3-k)-1].color == "black" ? "\e[30m" : "\e[97m" unless @captured[i*3 + (3-k)-1].nil?} "
        print "     #{@captured[i*3 + (3-k)-1].to_s unless @captured[i*3 + (3-k)-1].nil?} "
        print "#{@captured[i*3 + (3-k)-1 +24].color == "black" ? "\e[30m" : "\e[97m" unless @captured[i*3 + (3-k)-1 +24].nil?} "
        print "     #{@captured[i*3 + (3-k)-1 +24].to_s unless @captured[i*3 + (3-k)-1 +24].nil?} "
        print "\e[0m"
        puts ""
      end
      background = !background

    end
    print "   "
    ('a'..'h').each { |j| print j.center(6) }
    puts ""
  end

  def save
    print "enter file name:"
    file_name = gets.chomp
    File.open(file_name,'w') do |file|
      file.puts Marshal::dump(self)
    end
  end


end
