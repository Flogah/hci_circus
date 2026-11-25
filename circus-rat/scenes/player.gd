extends Node3D

@export var debug:bool = false
@export var acceleration:float = 5.0
@export var breaking: float = 5.0
@export var max_speed:float = 5.0
@export var input_manager: InputManager

@onready var rat: AnimatedSprite3D = $Rat
var rat_offset:Vector3 = Vector3.ZERO
@onready var ball: RigidBody3D = $Ball

var can_run:bool = true
var intended_dir: Vector3 = Vector3.ZERO

func _ready() -> void:
	rat_offset = rat.position - ball.position
	input_manager.input_direction_detected.connect(func(new_dir): intended_dir = new_dir)

func _physics_process(delta: float) -> void:
	animate_rat()
	rat.position = ball.position + rat_offset
	rotate_direction_to_camera()
	drive_ball(delta)

func drive_ball(delta):
	var desired_speed: float = max_speed * intended_dir.length()
	var curr_speed:float = ball.linear_velocity.length()
	var instant_speed:float = (desired_speed - curr_speed) / delta
	var accel_force = instant_speed * ball.mass
	var limited_force:float = clampf(accel_force, -breaking, acceleration)
	#print(limited_force)
	
	if debug:
		Draw3d.line(ball.global_position, ball.global_position + ball.linear_velocity.normalized() * limited_force, Color.HOT_PINK, 1)
		Draw3d.line(ball.global_position, ball.global_position + intended_dir * 2.0, Color.GREEN, 1)
		Draw3d.line(ball.global_position, ball.global_position + Vector3.UP * curr_speed, Color.RED, 1)
		#Draw3d.line(rat.global_position, rat.global_position + input_manager.leaning * 2.0, Color.AQUA, 1)
		
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

func animate_rat():
	# replace with figuring out velocity cross camera.RIGHT
	print(abs(ball.linear_velocity.x))
	if abs(ball.linear_velocity.x) < 0.2:
		#ball barely moves left/right
		rat.play("idle")
	else:
		rat.play("idle_facing")
		if ball.linear_velocity.x > 0.0:
			rat.flip_h = false
		elif ball.linear_velocity.x < 0.0:
			rat.flip_h = true
