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
@export var cloak_material: Material

const FLEE_DIST = 3.0
const PATHOFF_DELTA = 0.01
var velocity_spring := SpringVector3.new(1.0, 2.0, 0.0)
var nav_distance_threshold := 2.0

@onready var nav = $NavigationAgent3D
@onready var player = get_tree().current_scene.get_node("%Player")

func trigger_vaporize():
	if(behavior != Behavior.DEAD): $AnimationPlayer.play("vaporize");
	$AnimationTree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

@onready var body = %BodyMesh
@onready var cloak = %CloakMesh
func update_vaporize_material():
	body.set_surface_override_material(0, vaporize_material)
	cloak.set_surface_override_material(0, vaporize_material)

func do_death():
	behavior = Behavior.DEAD
	$CollisionShape3D.disabled = true

var last_offset := 0.0

func do_panic(_number):
	if behavior != Behavior.DEAD:
		behavior = Behavior.PANIC

func _ready():
	if cloak_material != null:
		cloak.set_surface_override_material(0, cloak_material)
	
	player.destroyed_npcs.connect(do_panic)
	# Make the navigation server happy
	set_physics_process(false)
	call_deferred("actor_setup")

func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	set_physics_process(true)

var current_target_position: Vector3
var current_path_target := Vector3.ZERO
var path_distance_threshold = 10.0

func _physics_process(delta: float) -> void:
	var velocity_target := Vector3.ZERO
	var current_speed: float = 0.0
	
	if behavior == Behavior.STANDING:
		velocity = Vector3i.ZERO
		move_and_slide()
		return
	
	elif behavior == Behavior.PATH_FOLLOW:
		var path: Path3D = get_node(path_target)
		if path != null:
			var current_offset := path.curve.get_closest_offset(global_position * path.transform)
			var offset: float = clamp(current_offset, last_offset, last_offset + PATHOFF_DELTA)
			
			last_offset = offset
			var path_coord := path.transform * path.curve.samplef(offset)
			
			current_target_position = path_coord
			current_speed = normal_speed
	
	elif behavior == Behavior.CURIOUS:
		var curious_direction: Vector3 = global_position - player.global_position
		var current_dist = curious_direction.length();
		var walk_direction = curious_direction.normalized() * (curious_distance - current_dist)
		
		current_target_position = global_position + walk_direction
		current_speed = normal_speed
	
	elif behavior == Behavior.PANIC:
		var flee_direction: Vector3 = (global_position - player.global_position).normalized() * FLEE_DIST
		
		current_target_position = global_position + flee_direction
		current_speed = panic_speed
	
	elif behavior == Behavior.DEAD:
		velocity = Vector3i.ZERO
		move_and_slide()
		return
	
	var direction := Vector3.ZERO
	if (nav.target_position - current_target_position).length() > nav_distance_threshold:
		nav.target_position = current_target_position
	
	if (current_path_target - global_position).length() < path_distance_threshold:
		current_path_target = nav.get_next_path_position()
	
	direction = current_path_target - global_position
	direction = direction.normalized()
	direction.y = 0.
	
	velocity_target = direction * current_speed
	
	velocity_spring.target = velocity_target
	velocity = velocity_spring.update(delta)
	$AnimationTree.set("parameters/Blend2/blend_amount", (velocity * Vector3(1., 0., 1.)).length() / panic_speed)
	
	if(velocity.length() > 0.1):
		$DenizenBodyMedium.rotation.y = atan2(velocity.x, velocity.z) - rotation.y
	
	move_and_slide()
