extends PLDActivatable
class_name PLDRiddle

signal riddle_error(riddle)
signal riddle_secret(riddle)
signal riddle_success(riddle)

export(DB.RiddleIds) var riddle_id = DB.RiddleIds.NONE

func connect_signals(target):
	if target.has_method("_on_riddle_secret"):
		connect("riddle_secret", target, "_on_riddle_secret")
	if target.has_method("_on_riddle_success"):
		connect("riddle_success", target, "_on_riddle_success")
	if target.has_method("_on_riddle_error"):
		connect("riddle_error", target, "_on_riddle_error")
