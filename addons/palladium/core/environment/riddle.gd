extends Spatial
class_name PLDRiddle

signal riddle_error(riddle)
signal riddle_success(riddle)

enum RiddleIds {
	NONE = 0,
	HEBE_BUTTONS = 10,
	PLANETS = 20
}
export(RiddleIds) var riddle_id = RiddleIds.NONE

func connect_signals(level):
	connect("riddle_success", level, "_on_riddle_success")
