extends SubViewportContainer

var current_level: String
var _current_level_node: Node = null
@export var player: Node = null
var _pause_menu: Node = null
var dialogue_box: Node = null
var _credits_screen: Node = null

var total_destroyed_npcs: int = 0

#############
# SAVE DATA #
#############
var fewest_deaths_run: int = -1

func save_fewest_deaths() -> void:
	if fewest_deaths_run >= 0:
		var save_file = FileAccess.open("user://savedata.save", FileAccess.WRITE)
		save_file.store_32(fewest_deaths_run)

func enter_paused_state(hide_timer: bool, show_cursor: bool) -> void:
	get_tree().paused = true
	if show_cursor:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_filter = Control.MOUSE_FILTER_STOP
	if hide_timer:
		$SubViewport/SceneContents/PlayerCountdown.visible = false

func exit_paused_state() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_filter = Control.MOUSE_FILTER_PASS
	$SubViewport/SceneContents/PlayerCountdown.visible = true
	grab_focus()

func show_dialogue(dialogue: PackedStringArray, is_final: bool = false) -> void:
	enter_paused_state(false, false)
	dialogue_box = preload("res://components/CharacterDialogue.tscn").instantiate()
	dialogue_box.dialogue = dialogue
	$SubViewport/SceneContents.add_child(dialogue_box)
	dialogue_box.completed.connect(func():
		$SubViewport/SceneContents.remove_child(dialogue_box)
		exit_paused_state()
		dialogue_box = null
		
		if is_final:
			show_credits()
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
	if FileAccess.file_exists("user://savedata.save"):
		var save_file = FileAccess.open("user://savedata.save", FileAccess.READ)
		fewest_deaths_run = save_file.get_32()
	
	change_level("bunker")
	
	update_subviewport()
	get_viewport().size_changed.connect(update_subviewport)

func _on_player_destroyed_npcs(destroyed_count: int) -> void:
	total_destroyed_npcs += destroyed_count
	
	var dialog = preload("res://components/DetonateQueryScreen.tscn").instantiate()
	dialog.death_count = total_destroyed_npcs
	dialog.accepted.connect(func():
		$SubViewport.remove_child(dialog)
		var end_screen = preload("res://components/GameOverScreen.tscn").instantiate()
		end_screen.destroyed_count = total_destroyed_npcs
		end_screen.best_run = fewest_deaths_run
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
	enter_paused_state(true, true)
	$SubViewport.add_child(dialog)

func _on_player_countdown_time_ran_out() -> void:
	player.trigger_purge()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if _credits_screen != null:
			$SubViewport.remove_child(_credits_screen)
			_credits_screen = null
			change_level("bunker")
			exit_paused_state()
			$SubViewport/SceneContents/PlayerCountdown.reset_to_default()
		
		elif dialogue_box != null:
			dialogue_box.advance()
	
	if event.is_action_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		if _pause_menu == null and get_tree().paused == false:
			enter_paused_state(false, true)
			_pause_menu = preload("res://assets/pause_menu.tscn").instantiate()
			_pause_menu.resume.connect(func():
				exit_paused_state()
				$SubViewport.remove_child(_pause_menu)
				_pause_menu = null
				self.grab_focus()
			)
			_pause_menu.visible = true
			$SubViewport.add_child(_pause_menu)

func show_credits() -> void:
	enter_paused_state(true, true)
	
	if fewest_deaths_run == -1 or total_destroyed_npcs < fewest_deaths_run:
		fewest_deaths_run = total_destroyed_npcs
		save_fewest_deaths()
	
	_credits_screen = preload("res://assets/credits_screen.tscn").instantiate()
	$SubViewport.add_child(_credits_screen)


func _on_audio_stream_player_finished() -> void:
	$SubViewport/AudioStreamPlayer.play()
