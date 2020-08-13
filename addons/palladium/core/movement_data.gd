extends Node
class_name PLDMovementData

var data = {}

func with_dir(dir):
	var d = Vector3(dir.x, dir.y, dir.z)
	data["dir"] = d
	return self

func with_distance(distance):
	data["distance"] = distance
	return self

func with_rest_state(rest_state):
	data["rest_state"] = rest_state
	return self

func with_rotation_angle(rotation_angle):
	data["rotation_angle"] = rotation_angle
	return self

func with_rotation_angle_to_target_deg(rotation_angle_to_target_deg):
	data["rotation_angle_to_target_deg"] = rotation_angle_to_target_deg
	return self

func with_signal(sgnl):
	data["sgnl"] = sgnl
	return self

func has_dir():
	return data.has("dir")

func has_distance():
	return data.has("distance")

func has_rest_state():
	return data.has("rest_state")

func has_rotation_angle():
	return data.has("rotation_angle")

func has_rotation_angle_to_target_deg():
	return data.has("rotation_angle_to_target_deg")

func has_signal():
	return data.has("sgnl")

func get_dir():
	return data["dir"] if has_dir() else Vector3()

func get_distance():
	return data["distance"] if has_distance() else 0

func get_rest_state():
	return data["rest_state"] if has_rest_state() else true

func get_rotation_angle():
	return data["rotation_angle"] if has_rotation_angle() else 0

func get_rotation_angle_to_target_deg():
	return data["rotation_angle_to_target_deg"] if has_rotation_angle_to_target_deg() else 0

func get_signal():
	return data["sgnl"] if has_signal() else null

func clear_dir():
	data.erase("dir")
	return self

func clear_distance():
	data.erase("distance")
	return self

func clear_rest_state():
	data.erase("rest_state")
	return self

func clear_rotation_angle():
	data.erase("rotation_angle")
	return self

func clear_rotation_angle_to_target_deg():
	data.erase("rotation_angle_to_target_deg")
	return self

func clear_signal():
	data.erase("sgnl")
	return self