extends SubViewportContainer

var _current_level: Node = null

func change_level(new_level: Resource) -> void:
	# TODO: begin loading screen
	
	if _current_level != null:
		$SubViewport.remove_child(_current_level)
	_current_level = new_level.instantiate()
	$SubViewport.add_child(_current_level)
	
	# TODO: end loading screen

func update_subviewport() -> void:
	var new_size = (Vector2((get_window().size)) / scale).ceil();
	$SubViewport.size = new_size
	
	var camera_size = new_size.y / Globals.pixels_per_meter
	$SubViewport.get_camera_3d().size = camera_size

func _ready() -> void:
	update_subviewport()
	get_viewport().size_changed.connect(update_subviewport)
	
	change_level(preload("res://scenes/levels/town_square.tscn"))
	#change_level(preload("res://scenes/levels/LevelLayOut.tscn")) #This is for testing.
	#change_level(preload("res://scenes/levels/town_small.tscn")) #This is for testing.

func _on_player_destroyed_npcs(destroyed_count: int) -> void:
	var dialog = preload("res://components/DetonateQueryScreen.tscn").instantiate()
	dialog.death_count = destroyed_count
	dialog.accepted.connect(func(): $SubViewport.remove_child(dialog))
	dialog.rejected.connect(func(): $SubViewport.remove_child(dialog))
	$SubViewport.add_child(dialog)
