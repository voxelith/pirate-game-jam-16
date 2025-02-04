extends CharacterBody3D

const SPEED := 5.0
const JUMP_VELOCITY := 3
const FRICTION := 0.01

const LOOK_SPEED := TAU / 20.0
const LOOK_FRICTION := 0.008
const MOUSE_SENSIVITY := 0.5
const MAX_MOUSE_MOVE := 100.0
const MOUSE_COOLDOWN := 3.0

const OCTAU = TAU / 8.0
var look_spring := SpringFloat.new(4.0, 4.0, 0.0)

var look_rotation := 0.0
var mouse_dir := 0.0

@onready var reticle = $Reticle
@onready var anim = $AnimationPlayer
@onready var body_anim = $GnomonBody.find_child("AnimationTree")

var destroyed_count: int = 0

signal destroyed_npcs

func reset_to_default() -> void:
	destroyed_count = 0
	look_rotation = 0
	mouse_dir = 0
	# TODO: figure out how to reset the camera

func _ready() -> void:
	look_rotation = rotation.y
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_dir = clamp(-event.relative.x * MOUSE_SENSIVITY, -MAX_MOUSE_MOVE, MAX_MOUSE_MOVE)

func _physics_process(delta: float) -> void:
	#################
	# PLAYER MOTION #
	#################
	if not anim.is_playing():
		var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var target = Vector3(0.0, velocity.y, 0.0)
		if direction:
			target += direction * SPEED
		
		velocity = lerp(velocity, target, pow(0.5, delta / FRICTION))
		
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		$GnomonBody.rotation.y = atan2(velocity.x, velocity.z) - rotation.y
		
	else:
		velocity = Vector3(0, 0, 0)
	
	#################
	# CAMERA MOTION #
	#################
	
	# Handle controller input
	var look_dir := Input.get_axis("look_right", "look_left")
	look_dir = look_dir * look_dir * sign(look_dir)
	
	# Handle mouse motion
	if mouse_dir:
		look_dir = mouse_dir
		mouse_dir = 0.0

	if look_dir:
		look_spring.target = look_rotation + (look_dir * LOOK_SPEED)
	
	look_rotation = look_spring.update(delta)
	rotation.y = look_rotation
	body_anim.set("parameters/Blend2/blend_amount", (velocity * Vector3(1., 0., 1.)).length() / SPEED)

	move_and_slide()

func trigger_purge():
	anim.play("purge")
	Input.start_joy_vibration(0, 1, 1, 2)

func find_and_destroy():
	###############
	# RAY CASTING #
	###############
	var space_state = get_world_3d().direct_space_state
	var origin: Vector3 = $PurgeLight.global_position;
	var destroyables = get_tree().get_nodes_in_group("destroyable")
	for destroyable in destroyables:
		var query = PhysicsRayQueryParameters3D.create(origin, destroyable.global_position)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			reticle.global_position = result.position
			if result.collider.has_method("trigger_vaporize"):
				result.collider.trigger_vaporize()
				destroyed_count += 1

func do_time_slowdown(value: float):
	Engine.time_scale = clamp(value, 0.01, 100.0)

func do_detation_screen():
	Engine.time_scale = 1.0
	if(destroyed_count > 0): destroyed_npcs.emit(destroyed_count)
