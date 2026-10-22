extends Node

const SAVE_PATH = "user://save_data.cfg"

var unlocked_level: int = 1
var completed_levels: Array[int] = []
var high_scores: Dictionary = {}

var selected_level: int = 1


func _ready():
	load_game()


# Save progress when a level is completed.
func complete_level(level: int, remaining_time: float):
	if not completed_levels.has(level):
		completed_levels.append(level)

	# Unlock the next level.
	unlocked_level = max(unlocked_level, level + 1)

	# Save the best remaining time for this level.
	var key = str(level)

	if not high_scores.has(key):
		high_scores[key] = remaining_time
	else:
		high_scores[key] = max(
			float(high_scores[key]),
			remaining_time
		)

	save_game()


func save_game():
	var config = ConfigFile.new()

	config.set_value("progress", "unlocked_level", unlocked_level)
	config.set_value("progress", "completed_levels", completed_levels)
	config.set_value("scores", "high_scores", high_scores)

	var error = config.save(SAVE_PATH)

	if error != OK:
		push_error("Could not save game data!")


func load_game():
	var config = ConfigFile.new()

	if not FileAccess.file_exists(SAVE_PATH):
		return

	var error = config.load(SAVE_PATH)

	if error != OK:
		push_error("Could not load game data!")
		return

	unlocked_level = int(
		config.get_value("progress", "unlocked_level", 1)
	)

	var saved_levels = config.get_value(
		"progress",
		"completed_levels",
		[]
	)

	completed_levels.clear()

	for level in saved_levels:
		completed_levels.append(int(level))

	high_scores = config.get_value(
		"scores",
		"high_scores",
		{}
	)
