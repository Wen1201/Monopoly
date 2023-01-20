require 'json'
require 'pry'

# first step is to load the board.json file into a Ruby variable so I can use it in the game code
file = File.read('board.json')
data_array = JSON.parse(file)
print data_array

# do the same thing with one of the dice files - and then how I would iterate over those dice roll numbers and use the rolls to move the players around the board
file = File.read('rolls_1.json')
dice_rolls = JSON.parse(file)
print dice_rolls


require 'pry'
binding.pry