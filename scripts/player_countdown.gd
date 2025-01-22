extends RichTextLabel

@export var time_left = 120


func _onTimerTick() -> void:
	time_left -= 1


# Hook into this when damage is taken
func applyDamage() -> void:
	time_left -= 10


func _ready() -> void:
	$Timer.timeout.connect(_onTimerTick)
	$Timer.start()


func _process(delta: float) -> void:
	text = "T-%d:%02d" % [time_left / 60, time_left % 60]
	pass
