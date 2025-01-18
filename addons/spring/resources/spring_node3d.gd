@tool
class_name SpringNode3D extends Node3D

@export var position_spring: SpringVector3
@export var scale_spring: SpringVector3
@export var rotation_spring: SpringQuaternion

@export var position_target: Vector3:
	set(value):
		position_spring.target = value
		position_target = value
@export_custom(PROPERTY_HINT_NONE, "radians_as_degrees") var rotation_target: Vector3:
	set(value):
		rotation_spring.target = Quaternion.from_euler(value).normalized()
		rotation_target = value
@export var scale_target: Vector3:
	set(value):
		scale_spring.target = value
		scale_target = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if position_spring:
		position_spring.position = position
		position_spring.target = position
		position_spring.prev_target = position
	if scale_spring:
		scale_spring.position = scale
		scale_spring.target = scale
		scale_spring.prev_target = scale
	if rotation_spring:
		var rotation_quat = Quaternion.from_euler(rotation).normalized()
		rotation_spring.position = rotation_quat
		rotation_spring.target = rotation_quat
		rotation_spring.prev_target = rotation_quat

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if position_spring: position = position_spring.update(delta)
	if scale_spring: scale = scale_spring.update(delta)
	if rotation_spring: rotation = rotation_spring.update(delta).normalized().get_euler()
