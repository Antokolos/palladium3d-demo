tool
extends Node

func get_all_name_hints():
	var result = []
	var properties = get_property_list()
	for i in range(properties.size()):
		if properties[i].name.ends_with("_NAME_HINT"):
			result.append(get(properties[i].name))
	return result

var PLAYER_NAME_HINT = "player"
var FEMALE_NAME_HINT = "female"
var BANDIT_NAME_HINT = "bandit"
