extends ColorRect

@onready var mvc = get_tree().current_scene.get_node("%MainViewportContainer")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var npc_death_dialogue_line: String
	if mvc.total_destroyed_npcs == 0:
		npc_death_dialogue_line = "And so, Gnomon left, breathing a sigh of relief..."
	elif mvc.total_destroyed_npcs < 8:
		npc_death_dialogue_line = "And so, Gnomon left, heavy-hearted..."
	else:
		npc_death_dialogue_line = "And so, Gnomon left, full of regret..."
	
	$VBoxContainer/Dialogue.text = npc_death_dialogue_line
	$VBoxContainer/DeathCount.text = "Entities purged: %d" % mvc.total_destroyed_npcs

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
