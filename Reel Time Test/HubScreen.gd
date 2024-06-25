extends Control

var current_game_choice = "Crazy Clowns"
var new_world = preload("res://World.tscn")


func change_game_type(new_game_choice):
	current_game_choice = new_game_choice
	
	for each in $PanelContainer/Control/PanelContainer/ScrollContainer/HBoxContainer.get_children():
		each.deselect_item()
		if each.game_choice == current_game_choice:
			each.select_item()
	


func _ready():
	var game_item_no_1 = $PanelContainer/Control/PanelContainer/ScrollContainer/HBoxContainer.get_child(0)
	change_game_type(game_item_no_1.game_choice)


func _on_button_pressed():
	get_tree().get_root().add_child(new_world.instantiate())
	self.queue_free()
