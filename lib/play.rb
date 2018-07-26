require_relative "Chess.rb"

## does not check any draw rules
## is is only really a problem for computer V computer

def string_to_moves(string)
  move = []
  return "nil" if string == ""
  string = string.downcase.strip
  string = string.split
  move << string[0]
  move << string[-1]
  move
end

def get_move(game)
  player = game.whos_turn
  return gets.chomp unless player.computer
  available_pieces = game.board.flatten.select do |piece|
    next if piece.nil?
    piece.get_valid_moves
    piece.color == player.color && piece.valid_moves.length > 0
   end
   piece = available_pieces.sample
   return [piece.position , piece.valid_moves.sample]


end

chess_string = "\u265A \u265B \u265C \u265D \u265E \u265F \u265A \u265B \u265C \u265D \u265E \u265F \u265A \u265B \u265C \u265D \u265E \u265F".split

puts
print "\e[43m"
puts (["\e[30m" , "\e[97m"]*9).zip(chess_string).flatten.join(" ") + "  \e[0m"
print "\e[43m"
puts (["\e[97m" , "\e[30m"]*9).zip(chess_string).flatten.join(" ") + "  \e[0m"
print "\e[0m"
puts "".center(55,"*")
puts "Chess".center(55,"*")
puts "".center(55,"*")
print "\e[43m"
puts (["\e[30m" , "\e[97m"]*9).zip(chess_string).flatten.join(" ") + "  \e[0m"
print "\e[43m"
puts (["\e[97m" , "\e[30m"]*9).zip(chess_string).flatten.join(" ") + "  \e[0m"
print "\e[0m"

# "\e[30m" : "\e[97m"

puts "type exit at anytime exit"
puts "type save at anytime to save and exit"
puts ""
puts "enter move in the format of : piece-position destination"
puts "exampes: 'g2 g3' or 'b8 to c6'"
puts ""
puts "press enter to start a new game"
print "or enter the name a savefile: "
loadfile = gets.chomp
if File.file?(loadfile)
  loadfile = File.read(loadfile)
  game = Marshal::load(loadfile)
else
  puts "\nFile not found Starting new game" unless loadfile.length == 0
  puts ""
  puts "leave name blank or enter computer for an AI player"
  puts ""
  print "White enter Name:"
  player_1 = gets.chomp
  print "Black enter Name:"
  player_2 = gets.chomp
  game = Chess.new(Player.new(player_1),Player.new(player_2))
end

game.print_board

loop do
  puts "" unless game.whos_turn.computer
  puts "#{game.whos_turn.color}: #{game.whos_turn.name} it is your turn" unless game.whos_turn.computer
  puts "your in check" if game.check && !game.whos_turn.computer
  print "#{game.whos_turn.color}: enter your move: " unless game.whos_turn.computer
  move = get_move(game)
  break if move == "exit"
  next game.save if move == "save"
  move = string_to_moves(move) if move.is_a? String
  play = game.move(move[0], move[1])
  puts play unless play == true unless game.whos_turn.computer
  if play == true
    game.next_turn
    check_mate = game.check_mate
    puts ""
    game.print_board
    puts "Check Mate" if check_mate == true
  end
  break if check_mate == true
end
# puts game.move_history.inspect
