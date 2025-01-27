extends Control

signal restart_requested

# TODO: replace these with some actual game quotes
var quotes = [
	"So long and thanks for all the fish!",
	"In the beginning the Universe was created. This has made a lot of people very angry and been widely regarded as a bad move.",
	"The ships hung in the sky in much the same way that bricks don’t.",
	"I'd far rather be happy than right any day.",
	"Ford, you're turning into a penguin. Stop it.",
	"The first ten million years were the worst, and the second ten million years, they were the worst too. The third ten million years I didn't enjoy at all. After that I went into a bit of a decline."
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HBoxContainer/EndQuote.text = quotes.pick_random()
	$HBoxContainer/HBoxContainer/Restart.grab_focus()
	
	$HBoxContainer/HBoxContainer/Restart.pressed.connect(func(): restart_requested.emit())
	# TODO: this should drop to the title screen
	$HBoxContainer/HBoxContainer/Quit.pressed.connect(func(): get_tree().quit())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
