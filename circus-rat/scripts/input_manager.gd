class_name InputManager extends Node

@export var osc_server: OSCServer

signal input_direction_detected(dir:Vector3)
signal jump_input_detected

var body_track_points:Array[Vector3] = [
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO,
	Vector3.ZERO,
]
var leaning:Vector3

var input_dict:Dictionary[String, float] = {
	"/nose:x": 0.0,
	"/nose:y": 0.0,
	"/nose:z": 0.0,
	"/right_shoulder:x": 0.0,
	"/right_shoulder:y": 0.0,
	"/right_shoulder:z": 0.0,
	"/left_shoulder:x": 0.0,
	"/left_shoulder:y": 0.0,
	"/left_shoulder:z": 0.0,
	"/right_hip:x": 0.0,
	"/right_hip:y": 0.0,
	"/right_hip:z": 0.0,
	"/left_hip:x": 0.0,
	"/left_hip:y": 0.0,
	"/left_hip:z": 0.0,
}

func _ready() -> void:
	osc_server.message_received.connect(print_message)

func print_message(_address, _value, _time):
	if input_dict.has(_address):
		input_dict[_address] = _value[0]

func _process(_delta: float) -> void:
	update_body_points()
	update_leaning()
	
	var flat_input:Vector3 = leaning
	flat_input.y = 0.0
	input_direction_detected.emit(flat_input)
	
	#var input:Vector2 = Input.get_vector("left", "right", "forward", "back")
	#var spatial_input:Vector3 = Vector3(input.x, 0.0, input.y)
	#input_direction_detected.emit(spatial_input)

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("manual_jump"):
		#jump_input_detected.emit()

func update_body_points():
	var point1:Vector3 = Vector3(input_dict["/nose:x"], input_dict["/nose:y"], input_dict["/nose:z"])
	var point2:Vector3 = Vector3(input_dict["/right_shoulder:x"], input_dict["/right_shoulder:y"], input_dict["/right_shoulder:z"])
	var point3:Vector3 = Vector3(input_dict["/left_shoulder:x"], input_dict["/left_shoulder:y"], input_dict["/left_shoulder:z"])
	var point4:Vector3 = Vector3(input_dict["/left_hip:x"], input_dict["/left_hip:y"], input_dict["/left_hip:z"])
	var point5:Vector3 = Vector3(input_dict["/right_hip:x"], input_dict["/right_hip:y"], input_dict["/right_hip:z"])
	var point6: Vector3 = (point4 + point5)/2.0
	
	body_track_points = [point1, point2, point3, point4, point5, point6]

func update_leaning():
	var avrg_shoulders = (body_track_points[1] + body_track_points[2])/2.0
	var avrg_hips = (body_track_points[3] + body_track_points[4])/2.0
	leaning = (avrg_shoulders - avrg_hips).normalized()
