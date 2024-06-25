extends Control



var tile_list = []
var spinning = false
var spin_down = false

var reel_peak_velocity = 0.2
var spin_down_velocity = 0.4
var spin_down_bump_duration = 0.15
var spin_up_bump_duration = 0.5
var spin_duration = 1.5
var spin_up_bump_distance = 3 ## fraction of tile size, tile_size / spin up bump distance = distance of bump
var spin_down_bump_distance = 3 ## fraction of tile size, tile_size / spin down bump distance = distance of bump
var tile_template = preload("res://TileTemplate.tscn")

var final_reel = [] : 
	set =  updateFinalReel
signal final_reel_updated
signal roll_complete

func updateFinalReel(new_reel):
	final_reel.append_array(new_reel)
	emit_signal("final_reel_updated")


@onready var tile_size = self.size.y / 5
@onready var centered_location = self.size.x/2 - tile_size/2
@onready var scroll_distance = self.size.y + tile_size  # total distance to scroll to get sprite offscreen before being freed


var target_item = 5
var tile_reference = {"Index":{
	"ImgPath":"",
	"Droprate":""
}
	
	
}

var saved_tile_referance = {
	
}




func _process(_delta):
	
	if spinning:
		_randomize_tile()
	if spin_down:
		_randomize_tile()
	
	

func stop_spinning():
		$Timer.stop()
		spinning = false
		spin_down = false 
		


func _randomize_tile():
	var rand_index = randi_range(0, tile_list.size()-1)
	var randomly_chosen_tile_index = (str(rand_index))
	
	if spin_down:
		var index = final_reel.pop_back()
		if index != null:
			randomly_chosen_tile_index = index

	
	var new_instance = $Tiles.get_node(str(randomly_chosen_tile_index)).duplicate(Node.DUPLICATE_USE_INSTANTIATION)
	new_instance.position.y = -tile_size
	$ReelContainer.add_child(new_instance)
	$ReelContainer.move_child(new_instance,0)


	if not spin_down:
		var tween = create_tween()
		tween.tween_property(new_instance, "position:y", scroll_distance, reel_peak_velocity).from_current().set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(self.delete.bind(new_instance))
		return
	
	if spin_down:
		var tween = create_tween()
		tween.tween_property(new_instance, "position:y", (tile_size * final_reel.size()) + (tile_size / spin_down_bump_distance), spin_down_velocity).from_current().set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(self.finalize_spin.bind(new_instance))
		
		if final_reel.size()  == 0:
			stop_spinning()
	
func delete(new_instance):
	new_instance.queue_free()


func finalize_spin(tile):
	var tween = create_tween()
	tween.tween_property(tile, "position:y", tile.position.y - (tile_size / 3), spin_down_bump_duration).from_current().set_trans(Tween.TRANS_LINEAR)
	$Animation/AnimationPlayer.play("SpinDown")
	if int(str(self.name)) == 4 and $ReelContainer.get_child(4) == tile:
		emit_signal("roll_complete")

				
func start_spinning():
	

	for each in $ReelContainer.get_children():
		each.stop_win_animation()
		
		var tween = create_tween()
		tween.tween_property(each, "position:y", each.position.y - (tile_size / spin_up_bump_distance), spin_up_bump_duration).from_current().set_trans(Tween.TRANS_BOUNCE)
		tween.tween_callback(self.engage_spin.bind(each))
	
	$Timer.start(spin_duration)

func engage_spin(tile):
	var tween = create_tween()
	tween.tween_property(tile, "position:y", scroll_distance, reel_peak_velocity).from_current().set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(self.delete.bind(tile))
	spinning = true

func _populate_tile_list():
	
	for each in Server.current_game_tile_values:
		print(each)
		var tile_id = each
		var sprite_fileName = Server.current_game_tile_values[tile_id]["Tile Icon"]
		var sprite_filePath = "res://Assets/" + Server.current_game + "/Tiles/" + sprite_fileName
		var texture = load(sprite_filePath)
		var sprite = tile_template.instantiate()
		sprite.set_texture(texture)
		sprite.set_custom_minimum_size(Vector2(0, tile_size))

		sprite.set_name(str(tile_list.size()))
		sprite.position.x = centered_location
		tile_reference[tile_id] = {"Img Path": sprite_fileName}##saved_tile_referance["res://Assets/" + Server.current_game + "/Tiles/" + fileName]
		tile_list.append([sprite_fileName, sprite])
		
	
	for each in tile_list:
		$Tiles.add_child(each[1], true)

	_generate_initial_tile_state()
		
func _generate_initial_tile_state():
	for each in tile_list.slice(0,5):
		for key in tile_reference:
			if tile_reference[key]["Img Path"] == each[0]:
				var copy_of_node = $Tiles.get_node(str(key)).duplicate(Node.DUPLICATE_USE_INSTANTIATION)
				var node = Node.new()
				node.set_name(each[0])
				copy_of_node.add_child(node, true)
				$ReelContainer.add_child(copy_of_node)
				copy_of_node.position.y = int(str(key)) * tile_size - (tile_size * 1)
				copy_of_node.position.x = self.size.x/2 - tile_size/2
		
	updateFinalReel([0,1,2,3,4])
	start_spinning()
	
	
		






	
func _initialize():
	
	tile_size = self.size.y / 5
	centered_location = self.size.x/2 - tile_size/2
	scroll_distance = self.size.y + tile_size  # total distance to scroll to get sprite offscreen before being freed

	tile_reference = {}
	_populate_tile_list()

	


func _on_timer_timeout():
	spinning = false
	spin_down = true


func highlight_tile(tile_number):
	$ReelContainer.get_child(tile_number).highlight_winning_tile()


