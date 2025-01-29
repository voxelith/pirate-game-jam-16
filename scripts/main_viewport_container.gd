extends SubViewportContainer

var current_level: String
var _current_level_node: Node = null
@export var player: Node = null
var _pause_menu: Node = null

func enter_paused_state() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_filter = Control.MOUSE_FILTER_STOP

func exit_paused_state() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_filter = Control.MOUSE_FILTER_PASS

func show_dialogue(dialogue: PackedStringArray) -> void:
	enter_paused_state()
	var dialogue_box = preload("res://components/CharacterDialogue.tscn").instantiate()
	dialogue_box.dialogue = dialogue
	$SubViewport/SceneContents.add_child(dialogue_box)
	dialogue_box.completed.connect(func():
		$SubViewport/SceneContents.remove_child(dialogue_box)
		exit_paused_state()
	)

func change_level(new_level_name: String) -> void:
	if player != null:
		player.destroyed_npcs.disconnect(_on_player_destroyed_npcs)
		$SubViewport/SceneContents.remove_child(player)
	player = preload("res://assets/player.tscn").instantiate()
	player.destroyed_npcs.connect(_on_player_destroyed_npcs)
	$SubViewport/SceneContents.add_child(player)
	
	if _current_level_node != null:
		$SubViewport.remove_child(_current_level_node)
	current_level = new_level_name
	_current_level_node = load("res://scenes/levels/%s.tscn" % current_level).instantiate()
	$SubViewport.add_child(_current_level_node)
	
	update_subviewport()

func update_subviewport() -> void:
	var new_size = (Vector2((get_window().size)) / scale).ceil();
	$SubViewport.size = new_size
	
	var camera_size = new_size.y / Globals.pixels_per_meter
	$SubViewport.get_camera_3d().size = camera_size

func _ready() -> void:
	change_level("bunker")
	
	update_subviewport()
	get_viewport().size_changed.connect(update_subviewport)

func _on_player_destroyed_npcs(destroyed_count: int) -> void:
	var dialog = preload("res://components/DetonateQueryScreen.tscn").instantiate()
	dialog.death_count = destroyed_count
	dialog.accepted.connect(func():
		$SubViewport.remove_child(dialog)
		var end_screen = preload("res://components/GameOverScreen.tscn").instantiate()
		end_screen.destroyed_count = destroyed_count
		end_screen.time_elapsed = $SubViewport/SceneContents/PlayerCountdown.total_activations * 30
		end_screen.restart_requested.connect(func():
			$SubViewport.remove_child(end_screen)
			change_level("bunker")
			$SubViewport/SceneContents/PlayerCountdown.reset_to_default()
			exit_paused_state()
		)
		$SubViewport.add_child(end_screen)
	)
	dialog.rejected.connect(func():
		$SubViewport/SceneContents/PlayerCountdown.restart()
		$SubViewport.remove_child(dialog)
		exit_paused_state()
	)
	enter_paused_state()
	$SubViewport.add_child(dialog)

func _on_player_countdown_time_ran_out() -> void:
	player.trigger_purge()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		if _pause_menu == null:
			print("pause spawn")
			_pause_menu = preload("res://assets/pause_menu.tscn").instantiate()
			_pause_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
			_pause_menu.resumed.connect(func():
				print("resume received")
				$SubViewport.remove_child(_pause_menu)
				_pause_menu = null
				self.grab_focus()
			)
			$SubViewport.add_child(_pause_menu)
			_pause_menu.pause()
