extends Camera3D

@onready var anim = $AnimationPlayer
@onready var camAudio = $CameraSound
@onready var picAudio = $ShutterSound

var cameraToggle = false
var opening: String = "CameraOverlay"
var closing: String ="CameraClose"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if Input.is_action_just_released("ToggleCamera"):
		if cameraToggle == false:
			if !anim.is_playing():
				print("OpenCamera!")
				anim.play("CameraOverlay")
				cameraToggle = true
				camAudio.play()
		else: if cameraToggle == true:
			if !anim.is_playing():
				print("CloseCamera!")
				anim.play("CameraClose")
				cameraToggle = false
	if Input.is_action_just_released("TakePicture"):
		if	cameraToggle == true:
			picAudio.play()

