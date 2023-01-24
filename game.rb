require 'json'
require 'pry'

# First step is to load the board.json file into a Ruby variable so I can use it in the game code.
file = File.read('board.json')
# add "symbolize_names: true",
# since board comes from JSON, keys are still strings, and not symbols
board = JSON.parse(file, symbolize_names: true) 
board.each do |space|
    # check if the type of space is "property", and if it is, 
    if space[:type] == "property"
    # setting the owner of that property to nil.
    # mean that no properties have an owner yet
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
    # check each player in the players array
    players.each do |player|
        # check if the position key in the player's hash is nil. 
        # If it is, it is setting the player's position key to 0.
        # make sure that each player has a starting position of 0 ,
        # in case the position key is not defined or is set to nil.
        if player[:position].nil?
            player[:position] = 0
        end
        # This line of code is taking the current player's position 
        # and using the modulo operator (%) to determine the remainder 
        # when the position is divided by the length of the board.
        # if a player's position is currently 10 and the board has 9 spaces, 
        # the modulo operation 10 % 9 would yield 1, 
        player[:position] = player[:position] % board.length
    end
    # sort players by money
    players.sort_by! { |player| player[:money] }.reverse!
    # print out the winner and the final scores
    puts "The winner is #{players.first[:name]} with $#{players.first[:money]}"
    puts "Final scores:"
    players.each do |player|
        puts "#{player[:name]}: $#{player[:money]} (on #{board[player[:position]][:name]})"
    end
end 

def buy_property(player, board, players)
    # use the modulus operator (%) to calculate the remainder of the player's current position 
    # divided by the length of the board. 
    # player's position to wrap around to the beginning of the board once they pass the last space.
    # player[:position] += dice_roll  
    # board has 10 spaces, peter 1+1+6+2=10, after 4 round, peter position is 1
    current_space = board[player[:position] % board.length]
    if player[:money] >= current_space[:price]
        player[:money] -= current_space[:price]
        current_space[:owner] = player
        # add current_space to the properties array of the player hash.
        # player[:properties].push(current_space)
        player[:properties] << current_space
        puts "#{player[:name]} bought #{current_space[:name]}"
        puts "#{player[:name]} has total $#{player[:money]}"
    else
        puts "#{player[:name]} can't afford #{current_space[:name]}"
        puts "#{player[:name]} is bankrupt, Game Over"
        game_over(players, board)
        exit
    end
end

#  check if the same owner owns all property of the same colour, the rent is doubled
def check_pay__double_rent(player, board, players)
    current_space = board[player[:position] % board.length]
    rent = current_space[:price]
    if current_space[:owner]
        rent_multiplier = check_rent_multiplier(board, current_space) 
        # multiply 1 or 2
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
            exit
        end
    end
end


def move_player( player, dice_roll, board, players) 
    # first store the player's current position in the old_position variable. 2 5
    # player's original position on the board is stored in the variable "old_position" 
    # by taking the current position and using the modulo operator to ensure it is within the bounds of the board length. 
        old_position = player[:position] % board.length
        # update the player's position by adding the dice roll to it    12 15 22
        player[:position] += dice_roll
        # store the new position in the new_position variable.  2 5 2
        # player's new position is then determined by adding the dice roll to 
        # their original position and storing it in the variable "new_position"
        new_position = player[:position] % board.length
        #  current space the player is on is then determined by 
        # taking the new position and using the modulo operator to ensure 
        # it is within the bounds of the board length and stored in the variable "current_space".
        current_space = board[player[:position] % board.length]
        # puts "The player is on #{current_space[:name]}"
        if current_space[:type] == "go"
            player[:money] += 1 unless player[:position] == 0
            puts "#{player[:name]} load on GO and collected $1"
            puts "#{player[:name]} has total $#{player[:money]}"
        elsif current_space[:type] == "property"
            # if the old_position is 8, new_position is 9, not pass go
            # if the old_position is 8, new_position is 2, new_position < old_position, pass go
            if new_position < old_position
                player[:money] += 1
                puts "#{player[:name]} passed GO and collected $1"
                puts "#{player[:name]} has total $#{player[:money]}"
            end
            if current_space[:owner].nil?
                buy_property(player, board, players)
            else
                if current_space[:owner] != player
                    check_pay__double_rent(player, board, players)
                end
            end
        end
        if player[:money] < 0
            puts "#{player[:name]} is bankrupt"
        end
end


    # a loop that prints out both the dice throw from the array, and the index of each throw 
    # dice_rolls is an array and index is the index of the current dice_roll in that array.
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
    move_player(current_player, dice_roll, board, players)    
             
end 

require 'pry'
binding.pry


  