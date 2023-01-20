require 'json'

file = File.read('board.json')
data_array = JSON.parse(file)
print data_array[1]



