require 'pry'

SUITES = ['h', 'd', 'c', 's'].freeze

MAX_NUMBER = 21
DEALER_STOP_NUM = 17

def prompt(msg)
  puts "=> #{msg}"
end

def prompt_break(msg)
  puts "----------------------"
  puts "=> #{msg}"
end

def clear_screen
  system('clear') || system('cls')
end

def initialize_deck
  new_deck = []
  SUITES.each do |suit|
    (1..13).each do |num|
      new_deck << [suit, num]
    end
  end
  new_deck
end

def rand_card!(deck)
  deck.delete_at(rand(deck.length))
end

def face_card_text(persons_hand, card)
  case persons_hand[card][1]
  when 2..10
    persons_hand[card][1].to_s
  when 11
    'Jack'
  when 12
    'Queen'
  when 13
    'King'
  else
    'Ace'
  end
end

def suit_text(persons_hand, card)
  case persons_hand[card][0]
  when 'h'
    "hearts"
  when 'd'
    "diamonds"
  when 'c'
    "clubs"
  else
    "spades"
  end
end

def hand_is_string(persons_hand, card = 0)
  hand = ''
  loop do
    hand << face_card_text(persons_hand, card)
    hand << " of #{suit_text(persons_hand, card)}"
    hand << "; " unless card == persons_hand.length - 1

    card += 1
    break if card == persons_hand.length
  end
  hand
end

def show_first_card(persons_hand)
  face_card_text(persons_hand, 0) + " of #{suit_text(persons_hand, 0)}"
end

def modify_for_aces(card_values, score)
  card_values.select { |card| card == 1 }.count.times do
    score -= 10 if score > MAX_NUMBER
  end
end

def hand_score(persons_hand)
  score = 0
  card_values = persons_hand.map { |card| card[1] }
  card_values.each do |value|
    score +=  case value
              when 1
                11
              when 10..13
                10
              else
                value
              end
  end
  modify_for_aces(card_values, score)
  score
end

def hit!(persons_hand, deck, player)
  persons_hand << rand_card!(deck)
  prompt_break "#{player.capitalize} Hits!"
end

def bust?(persons_hand)
  hand_score(persons_hand) > MAX_NUMBER
end

def winner?(player, dealer)
  player_hand_score = hand_score(player)
  dealer_hand_score = hand_score(dealer)
  if player_hand_score > MAX_NUMBER
    :player_busted
  elsif dealer_hand_score > MAX_NUMBER
    :dealer_busted
  elsif dealer_hand_score < player_hand_score
    :player
  elsif dealer_hand_score > player_hand_score
    :dealer
  else
    :tie
  end
end

def print_result(player_hand, dealer_hand, score)
  who_won = winner?(player_hand, dealer_hand)

  case who_won
  when :player_busted
    score['dealer'] += 1
    prompt_break "You busted! Dealer wins!"
  when :dealer_busted
    score['player'] += 1
    prompt_break "Dealer busted! You win!"
  when :player
    score['player'] += 1
    prompt_break "You win!"
  when :dealer
    score['dealer'] += 1
    prompt_break "Dealer wins!"
  when :tie
    prompt_break "It's a tie!"
  end
end

def show_hand_and_score(persons_hand, person)
  intro_string = ''
  intro_string = 'Your' if person == 'player'
  intro_string = 'Dealers' if person == 'dealer'

  prompt "#{intro_string} hand is: #{hand_is_string(persons_hand)}"
  prompt "#{intro_string} score is: #{hand_score(persons_hand)}"
end

def player_turn!(player_hand, deck)
  loop do
    hit_or_stay = ''
    show_hand_and_score(player_hand, 'player')
    loop do # user input checking
      prompt_break "Would you like to HIT or STAY? q to quit"
      hit_or_stay = gets.chomp.downcase
      break if %w(stay hit q).include?(hit_or_stay)
    end

    return 'quit' if hit_or_stay == 'q'
    hit!(player_hand, deck, 'player') if hit_or_stay == 'hit'
    break if bust?(player_hand) || hit_or_stay == 'stay'
  end
end

def dealer_turn!(dealer_hand, deck)
  show_hand_and_score(dealer_hand, 'dealer')
  sleep(1)

  loop do
    dealer_hand_score = hand_score(dealer_hand)
    if dealer_hand_score < DEALER_STOP_NUM
      hit!(dealer_hand, deck, 'dealer')
      show_hand_and_score(dealer_hand, 'dealer')
      sleep(1.5)
    elsif dealer_hand_score <= MAX_NUMBER
      prompt_break "Dealer Stays!"
      break
    else
      break
    end
  end
end

def play_again(score, first_game)
  clear_screen
  prompt_break "#{score.key(5).capitalize} won the game!"
  prompt "Would you like to play again? (y or n)"
  play_again = gets.chomp
  first_game_change(first_game)
  score['player'] = 0
  score['dealer'] = 0
  play_again == 'y'
end

def first_game_change(first_game)
  first_game[0] = !first_game[0]
end

def continue?(first_game, score)
  if score.values.include?(5)
    return true if play_again(score, first_game)
  elsif first_game[0]
    first_game_change(first_game)
    clear_screen
    prompt_break "Would you like to play first to 5? (y or n)"
    best_of_5 = gets.chomp
    return true if best_of_5.downcase.start_with?('y')
  elsif first_game[0] == false
    return true
  end
  false
end

score = { 'player' => 0, 'dealer' => 0 }
first_game = [true]

loop do
  clear_screen

  deck = initialize_deck
  dealer_hand = []
  player_hand = []

  2.times do
    dealer_hand << rand_card!(deck)
    player_hand << rand_card!(deck)
  end

  prompt "Welcome to 21." if first_game[0]
  prompt "Score: Player #{score['player']}; Dealer #{score['dealer']}" unless
    first_game[0]
  prompt "First to 5 wins" unless first_game[0]

  puts '----------------------'

  prompt "Dealer hand is #{show_first_card(dealer_hand)} and 'hidden card'"
  puts '' # line break for readibility

  break if player_turn!(player_hand, deck) == 'quit'
  if bust?(player_hand) # player busts
    show_hand_and_score(player_hand, 'player')
    print_result(player_hand, dealer_hand, score)
    sleep(2.5)
    continue?(first_game, score) ? next : break
  end

  dealer_turn!(dealer_hand, deck)

  puts "Your score: #{hand_score(player_hand)}; Dealer score:\
  #{hand_score(dealer_hand)}"
  print_result(player_hand, dealer_hand, score)
  sleep(2.5)
  bust?(dealer_hand)

  break unless continue?(first_game, score)
end

prompt_break "Thanks for playing 21!"
