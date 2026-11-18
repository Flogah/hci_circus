extends Node3D

@export var max_speed:float = 10.0
@export var turn_speed:float = 50.0
@export var min_turning_velocity:float = 1.0

@export var input_manager: InputManager

@export var traction_force:float = 0.5
@export var max_lean:float = 0.0

@onready var rat: Sprite3D = $Sprite3D
var rat_offset:Vector3 = Vector3.ZERO

@onready var ball: RigidBody3D = $Ball
@onready var steering_body: Node3D = %SteeringBody

var can_run:bool = true
var intended_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	rat_offset = ball.position - rat.position
	input_manager.input_direction_detected.connect(func(new_dir): intended_dir = new_dir)

func _physics_process(delta: float) -> void:
	drive_ball(delta)

func drive_ball(delta):
	rat.position = ball.position
	steering_body.position = ball.position
	
	# go forward
	#var speed_input: float = Input.get_axis("slow_down", "acceleration")
	var desired_speed: float = intended_dir.length() 
	var curr_fwd_speed:float = get_forward().dot(ball.linear_velocity)
	var instant_fwd_speed:float = (desired_speed - curr_fwd_speed) / delta
	var accel_force = instant_fwd_speed * ball.mass
	var limited_force:float = clampf(accel_force, -5.0, 5.0)
	
	if can_run:
		ball.apply_central_force(get_forward() * limited_force)
	else:
		ball.apply_central_force(-ball.linear_velocity)
	
	# traction
	var right = get_right()
	var current_side_speed:float = right.dot(ball.linear_velocity)
	var instant_side_accel:float = (0.0 - current_side_speed) / delta
	var side_force:float = instant_side_accel * ball.mass
	var limited_side_force:float = side_force * traction_force
	ball.apply_central_force(right * limited_side_force)

func get_forward() -> Vector3:
	return -steering_body.global_basis.z

func get_right() -> Vector3:
	return steering_body.basis.x
