extends Control

signal restart_requested

@export var destroyed_count: int = 0
@export var time_elapsed: int = 0
@export var best_run: int = -1

var quotes = [
	"...And so, Gnomon detonated. But it was not the end...",
	"...Gnomon awoke...",
	"...All around Gnomon was a desolate wasteland...",
	"...Gnomon knew that this was what its creators had wanted...",
	"...Gnomon had exacted the creators' petty judgment on humanity...",
	"...Now, only Gnomon remained..."
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/EndQuote.text = quotes.pick_random()
	$HBoxContainer/DeathCount.text = "Death count: %d" % destroyed_count
	if best_run >= 0:
		$HBoxContainer/DeathCount.text += " (best full run: %d)" % best_run
	$HBoxContainer/TimeElapsed.text = "Time elapsed: %d:%02d" % [int(time_elapsed / 60.), time_elapsed % 60]
	
	$HBoxContainer/HBoxContainer/Restart.grab_focus()
	$HBoxContainer/HBoxContainer/Restart.pressed.connect(func(): restart_requested.emit())
	
	if OS.get_name() == "Web":
		$HBoxContainer/HBoxContainer.remove_child($HBoxContainer/HBoxContainer/Quit)
	else:
		# TODO: this should drop to the title screen
		$HBoxContainer/HBoxContainer/Quit.pressed.connect(func(): get_tree().quit())
