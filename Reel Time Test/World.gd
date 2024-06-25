extends Control

var delay_between_reels = 0.1
var winning_lines = {}
var winnings = 0.0
var minimum_wager = 100

var first_drop_iteration = true

signal spin_complete

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().process_frame
	for each in $PanelContainer/HBoxContainer.get_children():
		each._initialize()
	$PanelContainer/HBoxContainer.get_child(4).connect("roll_complete", unlock_spin_button)
	$PanelContainer/HBoxContainer.get_child(4).connect("roll_complete", display_spin_results)
	Server.connect_spin_signal(self)

func display_spin_results():
	for each in winning_lines:
		$PanelContainer/WinningLinesContainer.get_node(each).visible = true
		$PanelContainer/WinningLinesContainer.get_node(each).start_win_animation()
	highlight_tiles(winning_lines)
	
	if not first_drop_iteration:
		if winning_lines.size() != 0:
			$Header._update_banner_text("You Won $" + str(winnings))
		else:
			$Header._update_banner_text("Bad Luck")
	first_drop_iteration = false
			
	
	emit_signal("spin_complete")

func unlock_spin_button():
	$Animation/AnimationPlayer.stop()
	$Control/HBoxContainer/Button.release_focus()
	$Control/HBoxContainer/Button.disabled = false

func _spin():
	for each in $PanelContainer/WinningLinesContainer.get_children():
		each.visible = false
		each.stop_win_animation()
	
	var current_wager = float($"Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Wager Field".text)
	
	var current_lines = int($Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Current_Lines_Label.get_text())
	$Control/HBoxContainer/Button.disabled = true
	var results_of_spin = await Server.generate_results_table(current_lines, current_wager)
	var results_array = results_of_spin[0]
	winning_lines = results_of_spin[1]
	winnings = results_of_spin[2]

	
	
	
	
	var child_count = $PanelContainer/HBoxContainer.get_child_count()
	while child_count != 0:
		await $PanelContainer/HBoxContainer.get_child(child_count -1).updateFinalReel(results_array[child_count -1])
		child_count -= 1

	$Animation/AnimationPlayer.play("Spinning")
	for each in $PanelContainer/HBoxContainer.get_children():
		await get_tree().create_timer(delay_between_reels).timeout
		each.start_spinning()
	

func highlight_tiles(winning_tiles_array):
	if winning_tiles_array.has("4") or winning_tiles_array.has("9"):
		if winning_tiles_array.has("4"):
			for each in winning_tiles_array["4"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(0)
		if winning_tiles_array.has("9"):
			for each in winning_tiles_array["9"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(0)
	
	if winning_tiles_array.has("2") or winning_tiles_array.has("7"):
		if winning_tiles_array.has("2"):
			for each in winning_tiles_array["2"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(1)
		if winning_tiles_array.has("7"):
			for each in winning_tiles_array["7"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(1)
	
	if winning_tiles_array.has("1") or winning_tiles_array.has("6"):
		if winning_tiles_array.has("1"):
			for each in winning_tiles_array["1"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(2)
		if winning_tiles_array.has("6"):
			for each in winning_tiles_array["6"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(2)
	
	if winning_tiles_array.has("3") or winning_tiles_array.has("8"):
		if winning_tiles_array.has("3"):
			for each in winning_tiles_array["3"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(3)
		if winning_tiles_array.has("8"):
			for each in winning_tiles_array["8"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(3)
	
	if winning_tiles_array.has("5") or winning_tiles_array.has("10"):
		if winning_tiles_array.has("5"):
			for each in winning_tiles_array["5"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(4)
		if winning_tiles_array.has("10"):
			for each in winning_tiles_array["10"]["Winning Tiles"]:
				$PanelContainer/HBoxContainer.get_node(str(each)).highlight_tile(4)
	
	
	
	# line 4/9
	# line 2/7
	# line 1/6
	# line 3/8
	# line 10 / 5


func _on_decrement_lines_pressed():
	var current_lines = int($Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Current_Lines_Label.get_text())
	current_lines -= 1
	if current_lines == 1:
		$Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Decrement_Lines.disabled = true
	$Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Current_Lines_Label.text = str(current_lines)
	$Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Increment_Lines.disabled = false
	
	for each in $PanelContainer/WinningLinesContainer.get_children():
		print(str(each.name))
		if int(str(each.name)) <= int(current_lines):
			each.visible = true
		else:
			each.visible = false
	$Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Decrement_Lines.release_focus()
	update_spin_button()



func _on_increment_lines_pressed():
	var current_lines = int($Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Current_Lines_Label.get_text())
	current_lines += 1
	if current_lines == 10:
		$Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Increment_Lines.disabled = true
	$Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Current_Lines_Label.text = str(current_lines)
	$Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Decrement_Lines.disabled = false
	
	for each in $PanelContainer/WinningLinesContainer.get_children():
		print(str(each.name))
		if int(current_lines) >= int(str(each.name)):
			each.visible = true
		else:
			each.visible = false
	$Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Increment_Lines.release_focus()
	update_spin_button()



func _on_wager_field_text_changed(new_text):
	if not new_text.is_valid_float():
		$"Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Wager Field".set_text(str(minimum_wager)) 
	if  float(new_text) < minimum_wager:
		$"Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Wager Field".set_text(str(minimum_wager)) 
	update_spin_button()

func _on_decrement_wager_button_pressed():
	var current_wager = float($"Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Wager Field".get_text())
	
	if float(current_wager) < float(minimum_wager) * 2:
		current_wager = minimum_wager
		$Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/Decrement_Wager_Button.disabled = true
	else:
		current_wager -= minimum_wager
	
	$"Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Wager Field".text = str(current_wager)
	$Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/Decrement_Wager_Button.release_focus()
	update_spin_button()


func _on_increment_wager_button_pressed():
	$Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/Decrement_Wager_Button.disabled = false
	var current_wager = float($"Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Wager Field".get_text())
	current_wager += minimum_wager
	$"Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Wager Field".text = str(current_wager)
	$Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/Increment_Wager_Button.release_focus()
	update_spin_button()
	
	
func update_spin_button():
	var current_lines = int($Control/HBoxContainer/Line_Parameters_Container/HBoxContainer/VBoxContainer/HBoxContainer/Current_Lines_Label.get_text())
	var current_wager = float($"Control/HBoxContainer/PanelContainer2/HBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/Wager Field".get_text())
	$Control/HBoxContainer/Button.text = "SPIN $" + str(current_wager * current_lines)
