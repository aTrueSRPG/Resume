extends Control

var game_hub_screen = preload("res://HubScreen.tscn")

func _on_button_pressed():
	var hub_instance = game_hub_screen.instantiate()
	get_tree().get_root().add_child(hub_instance)
	self.queue_free()


