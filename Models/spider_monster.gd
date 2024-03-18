extends Node3D

@export var movespeed: float = 2.0
@export var turn_speed: float = 1.0
@export var ground_offset: float = 2.0

signal caughtPlayer

@onready var fl_leg = $SpiderMonster/FrontLeftIKTarget
@onready var fr_leg = $SpiderMonster/FrontRightIKTarget

@onready var bl_leg = $SpiderMonster/RearLeftIKTarget
@onready var br_leg = $SpiderMonster/RearRightIKTarget

@onready var ml_leg = $SpiderMonster/MidLeftIKTarget
@onready var mr_leg = $SpiderMonster/MidRightIKTarget

@onready var player_body: Node3D 
@onready var spider_body = $SpiderMonster

func _ready():
	player_body = get_node("../PSXLayer/BlurPostProcess/Viewport/LCDOverlay/Viewport/DitherBanding/Viewport/World/Player")

func _process(delta):
	var plane1 = Plane(bl_leg.global_position, fl_leg.global_position, fr_leg.global_position)
	var plane2 = Plane(fr_leg.global_position, br_leg.global_position, bl_leg.global_position)
	var avg_normal = ((plane1.normal + plane2.normal) / 2).normalized()
	
	var target_basis = _basis_from_normal(avg_normal)
	transform.basis = lerp(transform.basis, target_basis, movespeed * delta).orthonormalized()
	
	var avg = (fl_leg.position + fr_leg.position + bl_leg.position + br_leg.position) / 4
	var target_pos = avg + transform.basis.y * ground_offset
	var distance = transform.basis.y.dot(target_pos - position)
	position = lerp(position, position + transform.basis.y * distance, movespeed * delta)
	
	var to_target = player_body.global_transform.origin - spider_body.global_transform.origin

	spider_body.global_transform = spider_body.global_transform.looking_at(spider_body.global_transform.origin - to_target.normalized(), Vector3.UP)
	_handle_movement(delta)
	
func _handle_movement(delta):
	position = position.move_toward(player_body.position, delta * movespeed) 
	#translate(Vector3(0,0,1) * movespeed * delta)

func _basis_from_normal(normal: Vector3) -> Basis:
	var result = Basis()
	result.x = normal.cross(transform.basis.z)
	result.y = normal
	result.z = transform.basis.x.cross(normal)

	result = result.orthonormalized()
	result.x *= scale.x 
	result.y *= scale.y 
	result.z *= scale.z 
	
	return result

func _on_kill_box_body_entered(body):
	if body.is_in_group("Player"):
		caughtPlayer.emit()
