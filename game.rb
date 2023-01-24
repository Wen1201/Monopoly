require 'json'
require 'pry'

# First step is to load the board.json file into a Ruby variable so I can use it in the game code.
file = File.read('board.json')
# add "symbolize_names: true",
# since board comes from JSON, keys are still strings, and not symbols
board = JSON.parse(file, symbolize_names: true) 
board.each do |space|
    if space[:type] == "property"
      space[:owner] = nil
    end
  end
# puts board

# do the same thing with one of the dice files. 
file = File.read('rolls_1.json')
dice_rolls = JSON.parse(file)
# puts dice_rolls

# make four player in an array, and each player’s information in a hash
players = [
    {
        name: "Peter",
        money: 16,
        properties: [],
        position: 0
    },
    {
        name: "Billy",
        money: 16,
        properties: [],
        position: 0
    },
    {
        name: "Charlotte",
        money: 16,
        properties: [],
        position: 0
    },
    {
        name: "Sweedal",
        money: 16,
        properties: [],
        position: 0
    }
]

def check_rent_multiplier(board, current_space)
    color = current_space[:colour]
    owner = current_space[:owner]

    # loop over the whole board
    board.each do |space|
      # check if the space has the same color as current_space
      if space[:colour] == color
        # check if the space has a different owner
        if space[:owner] != owner
          # if a space of the same color has a different owner, return 1 (no rent multiplier)
          return 1
        end
      end
    end
    # if all spaces of the same color have the same owner, return 2 (rent multiplier)
    return 2
  end

  def game_over(players, board)
    players.each do |player|
        if player[:position].nil?
            player[:position] = 0
        end
        player[:position] = player[:position] % board.length
    end
    players.sort_by! { |player| player[:money] }.reverse!
    puts "The winner is #{players.first[:name]} with $#{players.first[:money]}"
    puts "Final scores:"
    players.each do |player|
        puts "#{player[:name]}: $#{player[:money]} (on #{board[player[:position]][:name]})"
    end
end 

def buy_property(player, board)
    current_space = board[player[:position] % board.length]
    if player[:money] >= current_space[:price]
        player[:money] -= current_space[:price]
        current_space[:owner] = player
        player[:properties] << current_space
        puts "#{player[:name]} bought #{current_space[:name]}"
        puts "#{player[:name]} has total $#{player[:money]}"
    else
        puts "#{player[:name]} can't afford #{current_space[:name]}"
        game_over(players, board)
        # exit
    end
end

#  check if the same owner owns all property of the same colour, the rent is doubled
def pay__double_rent(player, board)
    current_space = board[player[:position] % board.length]
    rent = current_space[:price]
    if current_space[:owner]
        rent_multiplier = check_rent_multiplier(board, current_space) 
        rent *= rent_multiplier
        if player[:money] >= rent
            player[:money] -= rent
            current_space[:owner][:money] += rent
            puts "#{player[:name]} paid #{rent} to #{current_space[:owner][:name]} for landing on #{current_space[:name]}, #{player[:name]} has total $#{player[:money]}"
            puts "#{current_space[:owner][:name]} has total $#{current_space[:owner][:money]}"
        else
            puts "#{player[:name]} can't afford to pay #{rent} rent to #{current_space[:owner][:name]} for landing on #{current_space[:name]}"
            puts "#{player[:name]} is bankrupt, Game Over"
            game_over(players, board)
            # exit
        end
    end
end

game_over = false
def move_player( player, dice_roll, board) 
    # first store the player's current position in the old_position variable. 2 5
        old_position = player[:position] % board.length
        # update the player's position by adding the dice roll to it    12 15 22
        player[:position] += dice_roll
        # store the new position in the new_position variable.  2 5 2
        new_position = player[:position] % board.length
        current_space = board[player[:position] % board.length]
        # puts "The player is on #{current_space[:name]}"
        if current_space[:type] == "go"
            player[:money] += 1 unless player[:position] == 0
            puts "#{player[:name]} load on GO and collected $1"
            puts "#{player[:name]} has total $#{player[:money]}"
        elsif current_space[:type] == "property"
            if new_position < old_position
                player[:money] += 1
                puts "#{player[:name]} passed GO and collected $1"
                puts "#{player[:name]} has total $#{player[:money]}"
            end
            if current_space[:owner].nil?
                buy_property(player, board)
            else
                if current_space[:owner] != player
                    pay__double_rent(player, board)
                end
            end
        end
        if player[:money] < 0
            puts "#{player[:name]} is bankrupt"
        end
end

# if game_over
#     game_over(players, board)
#     exit
# end

    # a loop that prints out both the dice throw from the array, and the index of each throw 
dice_rolls.each_with_index do |dice_roll, index|
    # use index to create a new index into the players so it can take turns from 0,1,2,3 
    # and then "wrap" back to 0,1,2,3
    player_index = index % players.length
    # puts "dice roll #{player_index}: #{dice_roll}"
    # add the current dice roll to the position of the player at that inedx
    # players[player_index][:position] += dice_roll
    current_player = players[player_index]
    # puts "#{players[player_index][:name]}: #{players[player_index][:position]}"   
    
    # start defining functions 
    move_player(current_player, dice_roll, board)    
             
end 




  
  
  
  
  

# # sort players by money
# players.sort_by! { |player| player[:money] }.reverse!
# # print out the winner and the final scores
# puts "The winner is #{players.first[:name]} with $#{players.first[:money]}"
# puts "Final scores:"
# players.each do |player|
#     if player[:position].nil?
#         player[:position] = 0
#     end
#     player[:position] = player[:position] % board.length
#     puts "#{player[:name]}: $#{player[:money]} (on #{board[player[:position]][:name]})"
# end

  
  
  
  
  
  
require 'pry'
binding.pry


  