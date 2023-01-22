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

def move_player( player, dice_roll, board)
    player[:position] += dice_roll
    current_space = board[player[:position] % board.length]
    # puts "The player is on #{current_space[:name]}"
    if current_space[:type] == "go"
        player[:money] += 1 unless player[:position] == 0
    elsif current_space[:type] == "property"
        if current_space[:owner].nil?
            if player[:money] >= current_space[:price]
                player[:money] -= current_space[:price]
                current_space[:owner] = player
                player[:properties] << current_space
                puts "#{player[:name]} bought #{current_space[:name]}"
            else
                puts "#{player[:name]} can't afford #{current_space[:name]}"
            end
        else
            if current_space[:owner] != player
                rent = current_space[:price]
                # if the same owner owns all property of the same colour, the rent is doubled
                if current_space[:owner]
                    rent_multiplier = check_rent_multiplier(board, current_space) 
                    rent *= rent_multiplier
                end
                player[:money] -= rent
                current_space[:owner][:money] += rent
                puts "#{player[:name]} paid #{rent} to #{current_space[:owner][:name]} for landing on #{current_space[:name]}"
            end
        end
    end
    if player[:money] < 0
        puts "#{player[:name]} is bankrupt"
    end
end

# a loop that prints out both the dice throw from the array, and the index of each throw 
dice_rolls.each_with_index do |dice_roll, index|
    # use index to create a new index into the players so it can take turns from 0,1,2,3 
    # and then "wrap" back to 0,1,2,3
    player_index = index % players.length
    # add the current dice roll to the position of the player at that inedx
    # players[player_index][:position] += dice_roll
    current_player = players[player_index]
    # puts "#{players[player_index][:name]}: #{players[player_index][:position]}"   
  
    # start defining functions 
    move_player(current_player, dice_roll, board)
                
end 








  
require 'pry'
binding.pry


  