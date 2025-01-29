extends Control

signal restart_requested

@export var destroyed_count: int = 0
@export var time_elapsed: int = 0

# TODO: replace these with some actual game quotes
var quotes = [
	"… And so, Gnomon detonated. But it was not the end...",
	"...Gnomon awoke...",
	"...All around Gnomon was a desolate wasteland...",
	"...Gnomon knew that this was what its creators had wanted...",
	"...Gnomon had exacted their petty judgment on humanity...",
	"...Now, only Gnomon remained..."
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/EndQuote.text = quotes.pick_random()
	$HBoxContainer/GridContainer/DeathCount.text = "Death count: %d" % destroyed_count
	$HBoxContainer/GridContainer/TimeElapsed.text = "Time elapsed: %d:%02d" % [int(time_elapsed / 60.), time_elapsed % 60]
	
	$HBoxContainer/HBoxContainer/Restart.grab_focus()
	$HBoxContainer/HBoxContainer/Restart.pressed.connect(func(): restart_requested.emit())
	# TODO: this should drop to the title screen
	$HBoxContainer/HBoxContainer/Quit.pressed.connect(func(): get_tree().quit())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
