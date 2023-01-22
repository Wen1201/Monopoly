require 'json'
require 'pry'

# First step is to load the board.json file into a Ruby variable so I can use it in the game code.
file = File.read('board.json')
data_array = JSON.parse(file)
puts data_array

# do the same thing with one of the dice files. 
file = File.read('rolls_1.json')
dice_rolls = JSON.parse(file)
puts dice_rolls

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

# a loop that prints out both the dice throw from the array, and the index of each throw 
dice_rolls.each_with_index do |dice_roll, index|
    puts "dice roll #{player_index}: #{dice_roll}"
end


  
require 'pry'
binding.pry


  