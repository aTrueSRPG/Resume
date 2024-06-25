extends PanelContainer


func highlight_winning_tile():
	$TextureRect/AnimationPlayer.play("Fade_In_Out")

func set_texture(texture):
	$TextureRect.set_texture(texture)

func stop_win_animation():
	$TextureRect/AnimationPlayer.stop()
