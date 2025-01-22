extends SubViewportContainer


func update_subviewport() -> void:
	var new_size = (Vector2((get_window().size)) / scale).ceil();
	$SubViewport.size = new_size
	
	var camera_size = new_size.y / Globals.pixels_per_meter
	$SubViewport.get_camera_3d().size = camera_size

func _ready() -> void:
	update_subviewport()
	get_viewport().size_changed.connect(update_subviewport)

func pause():
	%PauseMenu.pause()
