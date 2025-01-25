extends RichTextLabel

@export var time_left: int = 30
@export var interval: int = 30

@onready var player = get_tree().current_scene.get_node("%Player")

func _onTimerTick() -> void:
	if time_left > 0:
		time_left -= 1
	else:
		player.trigger_purge()
		time_left = interval

# Hook into this when damage is taken
func applyDamage() -> void:
	time_left -= 10


func _ready() -> void:
	$Timer.timeout.connect(_onTimerTick)
	$Timer.start()


func _process(_delta: float) -> void:
	text = "T-%d:%02d" % [int(time_left / 60.), time_left % 60]
	pass
