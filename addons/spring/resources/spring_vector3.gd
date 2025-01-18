@tool
class_name SpringVector3 extends Spring

var prev_target: Vector3 = Vector3.ZERO
var position: Vector3 = Vector3.ZERO
var velocity: Vector3 = Vector3.ZERO

var target: Vector3 = Vector3.ZERO

func update(delta: float) -> Vector3:
	var xd: Vector3 = (target - prev_target) / delta
	prev_target = target
	
	var k2_stable: float = max(k2, 1.1 * (delta * delta * 0.5 + delta * k1 * 0.5), delta * k1)
	position = position + delta * velocity
	velocity = velocity + delta * (target + k3 * xd - position - k1 * velocity) / k2_stable;
	
	return position
