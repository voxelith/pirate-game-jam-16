extends CanvasLayer

@export var time_left: int = 30
@export var interval: int = 30

signal time_ran_out

func _onTimerTick() -> void:
	if time_left > 0:
		time_left -= 1
	else:
		time_ran_out.emit()
		time_left = interval

# Hook into this when damage is taken
func applyDamage() -> void:
	time_left -= 10


func _ready() -> void:
	$Timer.timeout.connect(_onTimerTick)
	$Timer.start()


func _process(_delta: float) -> void:
	$Label.text = "T-%d:%02d" % [int(time_left / 60.), time_left % 60]
	pass
