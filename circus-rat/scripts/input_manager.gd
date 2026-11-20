class_name InputManager extends Node

@export var osc_server: OSCServer

signal input_direction_detected(dir:Vector3)
signal jump_input_detected

func _ready() -> void:
	osc_server.message_received.connect(print_message)

func print_message(_address, _value, _time):
	print(_value)

func _process(_delta: float) -> void:
	var input:Vector2 = Input.get_vector("left", "right", "forward", "back")
	var spatial_input:Vector3 = Vector3(input.x, 0.0, input.y)
	input_direction_detected.emit(spatial_input)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("manual_jump"):
		jump_input_detected.emit()
