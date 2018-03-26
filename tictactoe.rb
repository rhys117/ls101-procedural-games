require 'pry'

INITIAL_MARKER = ' '.freeze
PLAYER_MARKER = 'X'.freeze
COMPUTER_MARKER = 'O'.freeze

WINNING_COMBOS =  [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

# rubocop:disable Metrics/AbcSize
def display_board(board)
  system 'clear'
  puts "You're a #{PLAYER_MARKER}; Computer is a #{COMPUTER_MARKER}"
  puts ""
  puts "     |     |"
  puts "  #{board[1]}  |  #{board[2]}  |  #{board[3]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{board[4]}  |  #{board[5]}  |  #{board[6]}"
  puts "     |     |"
  puts "-----+-----+-----"
  puts "     |     |"
  puts "  #{board[7]}  |  #{board[8]}  |  #{board[9]}"
  puts "     |     |"
end
# rubocop:enable Metrics/AbcSize

def prompt(msg)
  puts "=> #{msg}"
end

def initialize_board
  new_board = {}
  (1..9).each { |num| new_board[num] = INITIAL_MARKER }
  new_board
end

def valid_number?(num)
  Float(num).is_a?(Numeric)
  return true if num.to_i < 10
rescue; return false
end

def empty_squares(board)
  board.keys.select { |num| board[num] == INITIAL_MARKER }
end

def square_taken?(board, square)
  board.keys.select { |num| board[num] == INITIAL_MARKER }.include?(square.to_i)
end

def joiner(array, char=', ', word='or')
  if array.size > 1
    last_part_string = " #{word} #{array.pop}"
    first_part_string = array.join(char)
    joined_string = first_part_string + last_part_string
  else
    joined_string = array[0].to_s
  end
  joined_string
end

def computer_strat_logic(board, line, marker)
  if board.values_at(*line).count(marker) == 2 &&
     board.values_at(*line).count(INITIAL_MARKER) == 1
    line[board.values_at(*line).index(INITIAL_MARKER)]
  end
end

def place_piece!(board, current_player)
  square = nil

  if current_player == 'player'
    loop do
      prompt "Choose a square #{joiner(empty_squares(board))}"
      square = gets.chomp
      # check user input
      break if square_taken?(board, square) && valid_number?(square)
      prompt "That's not a valid number."
    end
    board[square.to_i] = PLAYER_MARKER
  end


  if current_player == 'computer'
    WINNING_COMBOS.each do |line|
      square = computer_strat_logic(board, line, COMPUTER_MARKER)
      break if square
    end

    if !square
      WINNING_COMBOS.each do |line|
        square = computer_strat_logic(board, line, PLAYER_MARKER)
        break if square
      end
    end

    if !square && board[5] == INITIAL_MARKER
      square = 5
    end

    square = empty_squares(board).sample if !square
    board[square] = COMPUTER_MARKER
  end

end

def board_full?(board)
  empty_squares(board).empty?
end

def detect_winner(board)
  WINNING_COMBOS.each do |line|
    if board.values_at(*line).count(PLAYER_MARKER) == 3
      return 'Player'
    elsif board.values_at(*line).count(COMPUTER_MARKER) == 3
      return 'Computer'
    end
  end
  nil
end

def someone_won?(board)
  !!detect_winner(board)
end

def alternate_player(current_player)
  if current_player == 'player'
    current_player = 'computer'
  else
    current_player = 'player'
  end
end


player_wins = 0
computer_wins = 0
game_counter = 0
current_player = nil

loop do
  board = initialize_board
  prompt "Would you like to go first? (y for yes!)"
  go_first_answer = gets.chomp

  if go_first_answer[0].downcase == 'y'
    current_player = 'player'
  else
    current_player = 'computer'
  end

  loop do
    display_board(board)

    prompt "Round: #{game_counter + 1}" unless game_counter.zero?
    prompt "Score. Player: #{player_wins}; Computer: #{computer_wins}" unless game_counter.zero?

    place_piece!(board, current_player)
    current_player = alternate_player(current_player)
    break if someone_won?(board) || board_full?(board)
  end

  display_board(board)

  if someone_won?(board)
    prompt "#{detect_winner(board)} won that round!"
    player_wins += 1 if detect_winner(board) == 'Player'
    computer_wins += 1 if detect_winner(board) == 'Computer'
  else
    prompt "It's a tie!"
  end

  if game_counter.zero?
    prompt "Would you like to play first to 5? (y or n)"
    best_of_5 = gets.chomp
    break unless best_of_5.downcase.start_with?('y')
  end

  game_counter += 1

  if computer_wins == 5 || player_wins == 5
    prompt "#{detect_winner(board)} won the game!"
    prompt "Would you like to play again? (y or n)"
    play_again = gets.chomp
    game_counter = 0
    computer_wins = 0
    player_wins = 0
    break unless play_again.downcase == 'y'
  end
end

prompt "Thanks for playing Tic Tac Toe!"
