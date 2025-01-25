extends CharacterBody3D

enum Behavior {
	STANDING,
	PATH_FOLLOW,
	CURIOUS,
	PANIC,
	DEAD
}

@export_range(0.5, 10.0, 0.1) var normal_speed: float = 2.5
@export_range(0.5, 10.0, 0.1) var panic_speed: float = 4.0
@export_range(2.0, 50.0, 0.1) var curious_distance: float = 10.0
@export var behavior: Behavior = Behavior.PANIC
@export_node_path("Node3D") var standing_target
@export_node_path("Path3D") var path_target
@export var vaporize_material: Material

const FLEE_DIST = 3.0
const PATHOFF_DELTA = 0.01
var velocity_spring := SpringVector3.new(1.0, 2.0, 0.0)

@onready var nav = $NavigationAgent3D
@onready var moving_target = get_tree().current_scene.get_node("%Player")

func trigger_vaporize():
	if(behavior != Behavior.DEAD): $AnimationPlayer.play("vaporize");

func update_vaporize_material():
	# $DenizenModel.set_surface_override_material(0, vaporize_material)
	pass

func do_death():
	behavior = Behavior.DEAD

var last_offset := 0.0

func _physics_process(delta: float) -> void:
	var velocity_target := Vector3.ZERO
	if behavior == Behavior.STANDING:
		var stand: Node3D = get_node(standing_target)
		if stand != null:
			nav.target_position = stand.global_position
			var direction: Vector3 = nav.get_next_path_position() - global_position
			direction = direction.normalized()
			direction.y = 0.
			
			velocity_target = direction * normal_speed
	elif behavior == Behavior.PATH_FOLLOW:
		var path: Path3D = get_node(path_target)
		if path != null:
			var current_offset = path.curve.get_closest_offset(global_position * path.transform)
			var offset = clamp(current_offset, last_offset, last_offset + PATHOFF_DELTA)
			
			last_offset = offset
			var path_coord = path.transform * path.curve.samplef(offset)
			
			nav.target_position = path_coord
			
			var direction: Vector3 = nav.get_next_path_position() - global_position
			direction = direction.normalized()
			direction.y = 0.
			
			velocity_target = direction * normal_speed
	
	elif behavior == Behavior.CURIOUS:
		var curious_direction: Vector3 = global_position - moving_target.global_position
		var current_dist = curious_direction.length();
		var walk_direction = curious_direction.normalized() * (curious_distance - current_dist)
		
		nav.target_position = global_position + walk_direction
		
		var direction: Vector3 = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		direction.y = 0.
		
		velocity_target = direction * normal_speed
	
	elif behavior == Behavior.PANIC:
		var flee_direction: Vector3 = (global_position - moving_target.global_position).normalized() * FLEE_DIST
		nav.target_position = global_position + flee_direction
	
		var direction: Vector3 = nav.get_next_path_position() - global_position
		direction = direction.normalized()
		direction.y = 0.
		
		velocity_target = direction * panic_speed
	
	velocity_spring.target = velocity_target
	velocity = velocity_spring.update(delta)

	$DenizenBodyMedium.rotation.y = atan2(velocity.x, velocity.z) - rotation.y
	
	move_and_slide()
