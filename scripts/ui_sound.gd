extends Node

@export var root_path : NodePath

#the audio player instances
@onready var sounds = {
	&"blip-focus" : AudioStreamPlayer.new(),
	&"blip-confirm" : AudioStreamPlayer.new(),
	}

func _ready() -> void:
	assert(root_path != null, "Empty root path for Interface Sounds!")

	#the set up for audio stream players and load sound files
	for i in sounds.keys():
		sounds[i].stream = load("res://sfx/" + str(i) + ".ogg")
		#assign output mixer bus
		sounds[i].bus = &"Sfx"
		#adds them to the scene tree
		add_child(sounds[i])

	#connect signals to the method that plays the sounds
	install_sounds(get_node(root_path))

#Add new ones for other nodes you want sound for
func install_sounds(node: Node) -> void:
	for i in node.get_children():
		if i is Button:
			i.mouse_entered.connect( ui_sfx_play.bind(&"blip-focus") )
			i.pressed.connect( ui_sfx_play.bind(&"blip-confirm") )
			i.focus_entered.connect( ui_sfx_play.bind(&"blip-focus") )

		elif i is OptionButton:
			i.mouse_entered.connect( ui_sfx_play.bind(&"blip-focus") )
			i.pressed.connect( ui_sfx_play.bind(&"blip-confirm") )
			i.focus_entered.connect( ui_sfx_play.bind(&"blip-focus") )

		elif i is TextureButton:
			i.mouse_entered.connect( ui_sfx_play.bind(&"blip-focus") )
			i.pressed.connect( ui_sfx_play.bind(&"blip-confirm") )
			i.focus_entered.connect( ui_sfx_play.bind(&"blip-focus") )

func ui_sfx_play(sound : String) -> void:
	sounds[sound].play()



#Why are you reading my code? I promise you, I didn't steal all of it! Stop! How dare you judge me! :( 
