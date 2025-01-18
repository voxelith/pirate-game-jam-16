@tool
class_name Spring extends Resource

@export_range(0.01, 10000, 0.01, "exp") var frequency: float = 1.:
	set(value):
		frequency = value
		calc_coefs()

@export_range(0., 3., 0.01, "or_greater") var damping: float = 0.5:
	set(value):
		damping = value
		calc_coefs()

@export_range(-1., 1., 0.01, "or_greater", "or_less") var response: float = 0.0:
	set(value):
		response = value
		calc_coefs()

var k1: float = 0
var k2: float = 0
var k3: float = 0
var delta_crit = 0

func calc_coefs():
	var tau_freq: float = TAU * frequency
	k1 = damping / (PI * frequency)
	k2 = 1. / (tau_freq * tau_freq)
	k3 = response * damping / tau_freq

func _init() -> void:
	calc_coefs()
