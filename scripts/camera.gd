extends Camera3D

@onready var target := $".."

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = round(target.global_position * Globals.pixels_per_meter) / Globals.pixels_per_meter
