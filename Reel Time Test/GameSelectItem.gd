extends PanelContainer

var game_choice = "Crazy Clowns"
var selected = false


func _on_mouse_entered():
	$Panel.get("theme_override_styles/panel").set("border_width_left", 8)
	$Panel.get("theme_override_styles/panel").set("border_width_right", 8)
	$Panel.get("theme_override_styles/panel").set("border_width_top", 8)
	$Panel.get("theme_override_styles/panel").set("border_width_bottom", 8)


func _on_mouse_exited():
	if not selected:
		$Panel.get("theme_override_styles/panel").set("border_width_left", 0)
		$Panel.get("theme_override_styles/panel").set("border_width_right", 0)
		$Panel.get("theme_override_styles/panel").set("border_width_top", 0)
		$Panel.get("theme_override_styles/panel").set("border_width_bottom", 0)



func select_item():
	selected = true
	$Panel.get("theme_override_styles/panel").set("border_width_left", 8)
	$Panel.get("theme_override_styles/panel").set("border_width_right", 8)
	$Panel.get("theme_override_styles/panel").set("border_width_top", 8)
	$Panel.get("theme_override_styles/panel").set("border_width_bottom", 8)
	
	
	
func deselect_item():
	selected = false
	$Panel.get("theme_override_styles/panel").set("border_width_left", 0)
	$Panel.get("theme_override_styles/panel").set("border_width_right", 0)
	$Panel.get("theme_override_styles/panel").set("border_width_top", 0)
	$Panel.get("theme_override_styles/panel").set("border_width_bottom", 0)
	
	


func _on_gui_input(event):
	if event is InputEventMouseButton:
		print ("clicked")
		self.get_tree().get_root().get_node("HubScreen").change_game_type(game_choice)
		
		
