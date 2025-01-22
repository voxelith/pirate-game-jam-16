extends CharacterBody3D

const SPEED := 3.5
const JUMP_VELOCITY := 3
const FRICTION := 0.01

const LOOK_SPEED := TAU / 11.25
const LOOK_FRICTION := 0.008
const MOUSE_SENSIVITY := 0.5
const MAX_MOUSE_MOVE := 100.0
const MOUSE_COOLDOWN := 3.0

const OCTAU = TAU / 8.0
var look_spring := SpringFloat.new(1.0, 2.0, 0.0)

var look_rotation := 0.0
var mouse_dir := 0.0
var mouse_move_last := 0.0

@onready var reticle = $Reticle

func _ready() -> void:
	look_rotation = rotation.y
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		mouse_dir = clamp(-event.relative.x * MOUSE_SENSIVITY, -MAX_MOUSE_MOVE, MAX_MOUSE_MOVE)
		mouse_move_last = 0.0
	elif event is InputEventKey:
		if event.is_action_pressed("pause_menu"):
			var mvc = get_tree().current_scene.get_node("%MainViewportContainer")
			if mvc != null:
				mvc.pause()
			get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	###############
	# RAY CASTING #
	###############
	var space_state = get_world_3d().direct_space_state
	var origin := global_position;
	var destroyables = get_tree().get_nodes_in_group("destroyable")
	for destroyable in destroyables:
		var query = PhysicsRayQueryParameters3D.create(origin, destroyable.global_position)
		query.exclude = [self]
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			reticle.global_position = result.position
	
	#################
	# PLAYER MOTION #
	#################
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var target = Vector3(0.0, velocity.y, 0.0)
	if direction:
		target += direction * SPEED
	
	velocity = lerp(velocity, target, pow(0.5, delta / FRICTION))
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
	
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
	mouse_move_last += delta
	
	# If it has been long enough since a mouse cooldown, snap camera angle to 45 deg. increment
	if mouse_move_last > MOUSE_COOLDOWN:
		look_spring.target = round(look_rotation / OCTAU) * OCTAU
	
	if look_dir:
		look_spring.target = look_rotation + (look_dir * LOOK_SPEED)
	
	look_rotation = look_spring.update(delta)
	rotation.y = look_rotation

	move_and_slide()
