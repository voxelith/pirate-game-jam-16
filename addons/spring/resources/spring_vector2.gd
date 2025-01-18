@tool
class_name SpringVector2 extends Spring

var prev_target: Vector2 = Vector2.ZERO
var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO

var target: Vector2 = Vector2.ZERO

func update(delta: float) -> Vector2:
	var xd: Vector2 = (target - prev_target) / delta
	prev_target = target
	
	var k2_stable: float = max(k2, 1.1 * (delta * delta * 0.5 + delta * k1 * 0.5), delta * k1)
	position = position + delta * velocity
	velocity = velocity + delta * (target + k3 * xd - position - k1 * velocity) / k2_stable;
	
	return position
