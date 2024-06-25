extends Node

var current_game_tile_distribution_table = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,2,2,2,2,2,3,3,3,3,3,4,4,4,4,4,5,5,5,5,5,6,6,6,6,6,7,7,7,7,7,8,8,8,8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,11,11,12,12,12,12,12,13,13,13,13,14,14,14,14,15,15,15,15,16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,22,22,22,23,23,23,24,24,24] ##


var current_game = "Crazy Clowns"
var current_reel_quantity = 5
var current_tiles_per_reel = 5
var current_game_tile_values = []

func load_game_data():
	var data_path = "res://Assets/" + current_game + "/Tile_Table.json"
	var file = FileAccess.open(data_path, FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	current_game_tile_distribution_table = content["Probability Table"]
	current_game_tile_values = content["Tiles"]


var tile_value_modifiers = {
	"3 Of A Kind":"1",
	"4 Of A Kind":"1.25",
	"5 Of A Kind":"1.75",
	
	
}

var users_balance = 1000000.00
signal users_balance_updated
var winnings = 0.0


func update_users_balance(deduct_or_add,value):
	print(str(users_balance) + " users balance")
	print(str(winnings) + " winnings")
	if deduct_or_add == "Deduct":
		users_balance -= value
	else:
		users_balance += winnings
	winnings = 0
	emit_signal("users_balance_updated")


func _ready():
	load_game_data()

func generate_results_table(current_lines, current_wager):
	var full_wager = current_lines * current_wager
	update_users_balance("Deduct", full_wager)
	var generated_game_array = []

	
	
	var reel_iterator = current_reel_quantity
	
	
	while reel_iterator > 0:
		var generated_reel_array = []
		var tile_iterator = current_tiles_per_reel
		while tile_iterator > 0 : # also the row/line iterator for the winnings test array
			var randomly_selected_index = randi_range(0, current_game_tile_distribution_table.size() -1)
			generated_reel_array.append(current_game_tile_distribution_table[randomly_selected_index])
			tile_iterator -= 1
		generated_game_array.append(generated_reel_array)
		reel_iterator -= 1
		

	
	var winnings_table = test_array_win_condition(generated_game_array, current_lines)
	winnings = winnings_table[1] * current_wager * 10
	
	return ([generated_game_array, winnings_table[0], winnings])
	
func test_array_win_condition(winnings_test_array, current_lines):

	
	var line_1_comparison_array = []
	var line_2_comparison_array = []
	var line_3_comparison_array = []
	var line_4_comparison_array = []
	var line_5_comparison_array = []
	
	
	for each in winnings_test_array:
		line_4_comparison_array.append(each[0])
		line_2_comparison_array.append(each[1])
		line_1_comparison_array.append(each[2])
		line_3_comparison_array.append(each[3])
		line_5_comparison_array.append(each[4])
	
	print("line 1 comparison array = " + str(line_1_comparison_array))
	
	var winning_lines = {}
	
	var reordered_comparison_array = [line_1_comparison_array,line_2_comparison_array,line_3_comparison_array,line_4_comparison_array,line_5_comparison_array]
	var iterator = reordered_comparison_array.size()
	winnings = 0.0
	
	
	while iterator > 0:
	
		if reordered_comparison_array[iterator -1][2] != reordered_comparison_array[iterator -1][1] and reordered_comparison_array[iterator -1][2] != reordered_comparison_array[iterator -1][3]:
			iterator -= 1
			continue
		## going forwards test condition

		if reordered_comparison_array[iterator -1][2] == reordered_comparison_array[iterator -1][1]:
			if reordered_comparison_array[iterator -1][2] == reordered_comparison_array[iterator -1][0]:
				var winning_tile_id = str(reordered_comparison_array[iterator -1][0])
				var winning_tile_value = float(current_game_tile_values[winning_tile_id]["Value"])
				var temp_winnings = 0.0
				if iterator <= current_lines:
					winning_lines[str(iterator)] = {"Winning Tiles": [0,1,2]} #### NEEDS to be a bet modifier 
					temp_winnings += winning_tile_value * float(tile_value_modifiers["3 Of A Kind"])
				if reordered_comparison_array[iterator -1][2] == reordered_comparison_array[iterator -1][3]:
					if iterator <= current_lines:
						winning_lines[str(iterator)] = {"Winning Tiles": [0,1,2,3]} #### NEEDS to be a bet modifier 
						temp_winnings += winning_tile_value * float(tile_value_modifiers["4 Of A Kind"])
					
					if reordered_comparison_array[iterator -1][2] == reordered_comparison_array[iterator -1][4]:
						if iterator <= current_lines:
							winning_lines[str(iterator)] = {"Winning Tiles": [0,1,2,3,4]} #### NEEDS to be a bet modifier
							temp_winnings += winning_tile_value * float(tile_value_modifiers["5 Of A Kind"]) 
				winnings += temp_winnings
						
		# reverse lines
		if reordered_comparison_array[iterator -1][2] == reordered_comparison_array[iterator -1][3]:
			if reordered_comparison_array[iterator -1][2] == reordered_comparison_array[iterator -1][4]:
				var winning_tile_id = str(reordered_comparison_array[iterator -1][2])
				var winning_tile_value = float(current_game_tile_values[winning_tile_id]["Value"])
				var temp_winnings = 0.0
				
				if winning_lines.has(str(iterator + 5)): # is already 5 of a kind going forward so will be 5 of a kinda going back too
					if (iterator + 5) <= current_lines:
						winning_lines[str(iterator + 5)]["Winning Tiles"].append_array([3,4])
						temp_winnings += winning_tile_value * float(tile_value_modifiers["5 Of A Kind"])
						winnings += temp_winnings
						iterator -= 1
						continue
					
				else:
					if (iterator + 5) <= current_lines:
						temp_winnings += winning_tile_value * float(tile_value_modifiers["3 Of A Kind"])
						winning_lines[str(iterator + 5)] = {"Winning Tiles": [2,3,4]} #### NEEDS to be a bet modifier 
				
				
				print("reordered comparison array = " + str (reordered_comparison_array[iterator -1]))
				if reordered_comparison_array[iterator -1][2] == reordered_comparison_array[iterator -1][1]:
					if (iterator + 5) <= current_lines:
						winning_lines[str(iterator + 5)]["Winning Tiles"] = [1,2,3,4]
						temp_winnings += winning_tile_value * float(tile_value_modifiers["4 Of A Kind"])
				winnings += temp_winnings
		iterator -= 1
	
	
	
	
	print(str(winning_lines) + " winning lines")
	
	return([winning_lines, winnings])
	
	
func connect_spin_signal(game_world_node):
	print("reading spin complete")
	game_world_node.connect("spin_complete", update_users_balance.bind("Add",winnings))
	
