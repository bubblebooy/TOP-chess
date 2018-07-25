require_relative "Chess.rb"

class Piece
  attr_accessor :position
  attr_reader :valid_moves
  attr_accessor :moved
  attr_reader :board
  attr_reader :color
  def initialize(position, color , board = Chess.new)
    @symbol = ["0","@"]
    @position = position
    @color = color #should this be player?
    @board = board
    @board.board[position[0]][position[1]] = self
    @moved = false
     # need to run such that everying is added 1st
  end

  def moves
    [[1,0]]
  end

  def get_valid_moves
    @valid_moves = moves

    @valid_moves = @valid_moves.select do |move|
      selector = true
      move[0] += position[0]
      move[1] += position[1]
      move.each{ |i| selector = false unless i>=0 && i<8}
       #|| @board[position[0]][position[1]].color != color
      selector
      # @board.valid_position?(move)
    end
    @valid_moves = @valid_moves.select do |move|
      selector = true
      selector = false unless @board.board[move[0]][move[1]].nil? || @board.board[move[0]][move[1]].color != color
      selector
    end
  end

  def to_s
    @color == "black" ? "#{@symbol[0]}" : "#{@symbol[0]}"

  end




end

#chess_pieces = ["\u265A","\u265B","\u265C","\u265D","\u265E","\u265F"]
# chess_pieces = ["\u2654","\u2655","\u2656","\u2657","\u2658","\u2659"]

class King < Piece
  def initialize(position, color , board = Chess.new)
    super(position, color , board)
    @symbol = ["\u265A","\u2654"]
  end
  def moves
    [1,-1,0,-1,1].permutation(2).to_a.uniq
  end
  def castle(rook)
    position = @position.dup
    return "King has moved" if @moved
    return "Rook has moved" if rook.moved
    return "King is in check" if @board.check
    range = [[@position[0]],[]]
    range[1] = @position[1] <= rook.position[1] ? (@position[1]..rook.position[1]).to_a : (rook.position[1]..@position[1]).to_a.reverse
    range = range[0].product(range[1])
    return "There are pieces between the king and the rook" unless range[1..-2].all? { |e| @board.board[e[0]][e[1]].nil? }

    return "The king can not pass through squares that are under attack" if @board.move(range[0],range[1]) != true
    if @board.move(range[1],range[2]) != true
      @board.move(range[1],range[0])
      @board.move_history.pop(2)
      return "The king can not end up in check"
    end
    @board.board[range[1][0]][range[1][1]] = rook
    @board.board[range[-1][0]][range[-1][1]] = nil
    @board.move_history.pop(2)
    @board.move_history << ["castle",rook.position]
    true

  end
end

class Queen < Piece
  def initialize(position, color , board = Chess.new)
    super(position, color , board)
    @symbol = ["\u265B","\u2655"]
  end
  def moves
    moves = Array.new(17) { |i|  [-8 + i, -8 + i]} + Array.new(17) { |i|  [-8 + i, 8 - i]}
    moves += (-8..8).to_a.product([0])
    moves += [0].product((-8..8).to_a)
    moves.uniq
  end
  def get_valid_moves
    super
    @valid_moves = @valid_moves.select do |move|
      selector = false
      range = [[],[]]
      range[0] = position[0] <= move[0] ? (position[0]..move[0]).to_a : (move[0]..position[0]).to_a.reverse
      range[1] = position[1] <= move[1] ? (position[1]..move[1]).to_a : (move[1]..position[1]).to_a.reverse
      (position[0] == move[0] || position[1] == move[1]) ? range = range[0].product(range[1]) : range = range[0].zip(range[1])
      selector = true if range.length == 2
      selector = true if range[1..-2].all? { |e| @board.board[e[0]][e[1]].nil? }
      # puts (position[0]..move[0])
      selector
    end
  end
end

class Rook < Piece
  def initialize(position, color , board = Chess.new)
    super(position, color , board)
    @symbol = ["\u265C","\u2656"]
  end
  def moves
    moves = []
    moves += (-8..8).to_a.product([0])
    moves += [0].product((-8..8).to_a)
    moves.uniq
  end
  def get_valid_moves
    super
    @valid_moves = @valid_moves.select do |move|
      selector = false
      range = [[],[]]
      range[0] = position[0] <= move[0] ? (position[0]..move[0]).to_a : (move[0]..position[0]).to_a.reverse
      range[1] = position[1] <= move[1] ? (position[1]..move[1]).to_a : (move[1]..position[1]).to_a.reverse
      range = range[0].product(range[1])
      selector = true if range.length == 2
      selector = true if range[1..-2].all? { |e| @board.board[e[0]][e[1]].nil? }
      # puts (position[0]..move[0])
      selector
    end
  end
end


class Bishop < Piece
  def initialize(position, color , board = Chess.new)
    super(position, color , board)
    @symbol = ["\u265D","\u2657"]
  end
  def moves
    (Array.new(17) { |i|  [-8 + i, -8 + i]} + Array.new(17) { |i|  [-8 + i, 8 - i]}).uniq
  end
  def get_valid_moves
    super
    @valid_moves = @valid_moves.select do |move|
      selector = false
      range = [[],[]]
      range[0] = position[0] <= move[0] ? (position[0]..move[0]).to_a : (move[0]..position[0]).to_a.reverse
      range[1] = position[1] <= move[1] ? (position[1]..move[1]).to_a : (move[1]..position[1]).to_a.reverse
      range = range[0].zip(range[1])
      selector = true if range.length == 2
      selector = true if range[1..-2].all? { |e| @board.board[e[0]][e[1]].nil? }
      # puts (position[0]..move[0])
      selector
    end
  end
end

class Knight < Piece
  def initialize(position, color , board = Chess.new)
    super(position, color , board)
    @symbol = ["\u265E","\u2658"]
  end
  def moves
    moves = [[1,2],[2,1],[-1,2],[-2,1],[1,-2],[2,-1],[-1,-2],[-2,-1]]
  end
end

class Pawn < Piece
  def initialize(position, color , board = Chess.new)
    super(position, color , board)
    @symbol = ["\u265F","\u2659"]
  end
  def moves
    moves = [[1,0],[1,-1],[1,1]]
    moves << [2,0] if @moved == false
    moves.map! { |move| [-move[0],move[1]] } if color == "black"
    # puts moves.inspect
    moves
  end
  def get_valid_moves
    @valid_moves = moves
    @valid_moves = @valid_moves.select do |move|
      selector = true
      move[0] += position[0]
      move[1] += position[1]
      move.each{ |i| selector = false unless i>=0 && i<8}
      selector
    end
    @valid_moves = @valid_moves.select do |move|
      selector = false
      selector = true if @board.board[move[0]][move[1]].nil? && move[1] == position[1]
      selector = true if !@board.board[move[0]][move[1]].nil? && @board.board[move[0]][move[1]].color != @color && move[1] != position[1]

      selector = false if (move[0] - position[0]).abs == 2 && !@board.board[(move[0]+position[0])/2][move[1]].nil?
      last_move = board.move_history[-1].dup unless board.move_history[-1].nil?         #En passant
      if !last_move.nil? && board.board[last_move[1][0]][last_move[1][1]].is_a?(Pawn)   #En passant
        if (last_move[1][0]-last_move[0][0]).abs == 2                                   #En passant
          last_move[0] = (last_move[1][0]+last_move[0][0])/2                            #En passant
          last_move[1] = last_move[1][1]                                                #En passant
          selector = true if move == last_move                                          #En passant
        end
      end
      selector
    end

  end
  def promote
    print "promote pawn to Queen, Rook, Bishop, or Knight: "
    choice = @board.whos_turn.computer ? "queen" : gets.chomp.downcase
    case choice
    when "queen"
      @board.board[@position[0]][@position[1]] = Queen.new(@position,@color,@board)
    when "rook"
      @board.board[@position[0]][@position[1]] = Rook.new(@position,@color,@board)
    when "bishop"
      @board.board[@position[0]][@position[1]] = Bishop.new(@position,@color,@board)
    when "knight"
      @board.board[@position[0]][@position[1]] = Knight.new(@position,@color,@board)
    else
      promote
    end
  end
end
