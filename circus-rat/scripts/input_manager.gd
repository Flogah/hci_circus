class_name InputManager extends Node

@export var osc_server: OSCServer

signal input_direction_detected(dir:Vector3)
signal jump_input_detected

var triangle:ImmediateMesh
var normal:Vector3

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
}

func _ready() -> void:
	triangle = ImmediateMesh.new()
	update_triangle()
	osc_server.message_received.connect(print_message)

func print_message(_address, _value, _time):
	if input_dict.has(_address):
		input_dict[_address] = _value[0]

func _process(_delta: float) -> void:
	construct_triangle()
	#var input:Vector2 = Input.get_vector("left", "right", "forward", "back")
	#var spatial_input:Vector3 = Vector3(input.x, 0.0, input.y)
	#input_direction_detected.emit(spatial_input)
#
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("manual_jump"):
		#jump_input_detected.emit()

func construct_triangle():
	var point1:Vector3 = Vector3(input_dict["/nose:x"], input_dict["/nose:y"], input_dict["/nose:z"])
	var point2:Vector3 = Vector3(input_dict["/right_shoulder:x"], input_dict["/right_shoulder:y"], input_dict["/right_shoulder:z"])
	var point3:Vector3 = Vector3(input_dict["/left_shoulder:x"], input_dict["/left_shoulder:y"], input_dict["/left_shoulder:z"])
	triangle.clear_surfaces()
	update_triangle()
	
	var v1 = point1 - point2
	var v2 = point1 - point3
	var cross = v2.cross(v1)
	#print(cross)
	normal = cross

func update_triangle():
	var point1:Vector3 = Vector3(input_dict["/nose:x"], input_dict["/nose:y"], input_dict["/nose:z"])
	var point2:Vector3 = Vector3(input_dict["/right_shoulder:x"], input_dict["/right_shoulder:y"], input_dict["/right_shoulder:z"])
	var point3:Vector3 = Vector3(input_dict["/left_shoulder:x"], input_dict["/left_shoulder:y"], input_dict["/left_shoulder:z"])
	
	triangle.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	triangle.surface_add_vertex(point1)
	triangle.surface_add_vertex(point2)
	triangle.surface_add_vertex(point3)
	triangle.surface_end()
