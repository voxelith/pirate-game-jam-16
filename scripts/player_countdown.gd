extends CanvasLayer

@export var time_left: int = 30
@export var interval: int = 30
# We export total activations instead of total seconds to avoid small errors from accumulating and
# causing the endscreen value to get out of whack with the actual number of timers that were shown.
@export var total_activations: int = 0

signal time_ran_out

func _onTimerTick() -> void:
	if time_left > 0:
		time_left -= 1
	else:
		time_ran_out.emit()
		time_left = interval
		total_activations += 1

# Hook into this when damage is taken
func applyDamage() -> void:
	time_left -= 10


func _ready() -> void:
	$Timer.timeout.connect(_onTimerTick)
	$Timer.start()


func _process(_delta: float) -> void:
	$Label.text = "T-%d:%02d" % [int(time_left / 60.), time_left % 60]
	pass

func reset_to_default() -> void:
	time_left = 30
	total_activations = 0
