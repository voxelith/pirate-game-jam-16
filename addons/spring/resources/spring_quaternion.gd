@tool
class_name SpringQuaternion extends Spring

var prev_target: Quaternion = Quaternion.IDENTITY
var position: Quaternion = Quaternion.IDENTITY
var velocity: Quaternion = Quaternion.IDENTITY

var target: Quaternion = Quaternion.IDENTITY

func update(delta: float) -> Quaternion:
	if target.dot(position) < 0:
		target = Quaternion(-target.x, -target.y, -target.z, -target.w)
	var xd: Quaternion = (target - prev_target) / delta
	prev_target = target
	
	var k2_stable: float = max(k2, 1.1 * (delta * delta * 0.5 + delta * k1 * 0.5), delta * k1)
	position = position + delta * velocity
	velocity = velocity + delta * (target + k3 * xd - position - k1 * velocity) / k2_stable;
	
	return position
