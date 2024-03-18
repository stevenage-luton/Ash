extends CanvasLayer


func _input(event):
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
		