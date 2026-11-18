extends Node3D

@export var debug:bool = false
@export var acceleration:float = 5.0
@export var breaking: float = 5.0
@export var max_speed:float = 20.0
@export var input_manager: InputManager

@onready var rat: Sprite3D = $Sprite3D
var rat_offset:Vector3 = Vector3.ZERO
@onready var ball: RigidBody3D = $Ball

var can_run:bool = true
var intended_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	rat_offset = rat.position - ball.position
	input_manager.input_direction_detected.connect(func(new_dir): intended_dir = new_dir)

func _physics_process(delta: float) -> void:
	rat.position = ball.position + rat_offset
	rotate_direction_to_camera()
	drive_ball(delta)

func drive_ball(delta):
	var desired_speed: float = max_speed * intended_dir.length()
	var curr_speed:float = ball.linear_velocity.length()
	var instant_speed:float = (desired_speed - curr_speed) / delta
	var accel_force = instant_speed * ball.mass
	var limited_force:float = clampf(accel_force, -breaking, acceleration)
	print(limited_force)
	
	if debug:
		Draw3d.line(ball.global_position, ball.global_position + ball.linear_velocity.normalized() * limited_force, Color.HOT_PINK, 1)
		Draw3d.line(ball.global_position, ball.global_position + intended_dir * 2.0, Color.GREEN, 1)
		Draw3d.line(ball.global_position, ball.global_position + Vector3.UP * curr_speed, Color.RED, 1)
	
	if can_run:
		if intended_dir.length_squared() > 0.0:
			ball.apply_central_force(intended_dir * limited_force)
		else:
			ball.apply_central_force( ball.linear_velocity.normalized() * limited_force)
	else:
		ball.apply_central_force(-ball.linear_velocity)

func rotate_direction_to_camera():
	var current_camera = get_viewport().get_camera_3d()
	intended_dir = intended_dir.rotated(Vector3.UP, current_camera.global_rotation.y).normalized()
