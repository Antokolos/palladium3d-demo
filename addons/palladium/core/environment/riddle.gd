extends Spatial
class_name PLDRiddle

signal riddle_error(riddle)
signal riddle_success(riddle)

export(DB.RiddleIds) var riddle_id = DB.RiddleIds.NONE

func connect_signals(level):
	connect("riddle_success", level, "_on_riddle_success")
