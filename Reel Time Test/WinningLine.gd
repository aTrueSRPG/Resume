extends Line2D

func start_win_animation():
	$AnimationPlayer.play("Fade_In_Out")

func stop_win_animation():
	$AnimationPlayer.stop()
