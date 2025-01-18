@tool
class_name SpringFloat extends Spring

var prev_target: float = 0
var position: float = 0
var velocity: float = 0

var target: float = 0

func update(delta: float) -> float:
	var xd: float = (target - prev_target) / delta
	prev_target = target
	
	var k2_stable: float = max(k2, 1.1 * (delta * delta * 0.5 + delta * k1 * 0.5), delta * k1)
	position = position + delta * velocity
	velocity = velocity + delta * (target + k3 * xd - position - k1 * velocity) / k2_stable;
	
	return position
