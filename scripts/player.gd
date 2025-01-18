extends CharacterBody3D

const SPEED := 3.5
const JUMP_VELOCITY := 3
const FRICTION := 0.01

const LOOK_SPEED := TAU / 11.25
const LOOK_FRICTION := 0.008
const MOUSE_SENSIVITY := 0.5
const MOUSE_COOLDOWN := 1.0

const OCTAU = TAU / 8.0
@export var look_spring: SpringFloat

var look_rotation := 0.0
var mouse_dir := 0.0
var mouse_move_last := 0.0

func _ready() -> void:
	look_rotation = rotation.y
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_dir = -event.relative.x
		mouse_move_last = 0.0

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
	
	# Add player/camera rotation
	var look_dir := Input.get_axis("look_left", "look_right")
	if mouse_dir:
		look_dir = mouse_dir * MOUSE_SENSIVITY
		mouse_dir = 0.0
	else:
		look_dir *= look_dir * sign(look_dir)
	
	mouse_move_last += delta
	if mouse_move_last > MOUSE_COOLDOWN:
		look_spring.target = round(look_rotation / OCTAU) * OCTAU
	
	if look_dir:
		look_spring.target = look_rotation + (look_dir * LOOK_SPEED)
	
	look_rotation = look_spring.update(delta)
	rotation.y = look_rotation

	move_and_slide()
