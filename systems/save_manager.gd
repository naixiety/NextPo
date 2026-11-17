
extends Node

const SAVE_PATH := "user://savegame.json"

var current_day: int = 1
var citations: int = 0
var public_trust: int = 50


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func new_game() -> void:
	current_day = 1
	citations = 0
	public_trust = 50
	save_game()


func save_game() -> void:
	var data := {
		"current_day": current_day,
		"citations": citations,
		"public_trust": public_trust
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("Unable to save game.")
		return

	file.store_string(JSON.stringify(data))
	file.close()


func load_game() -> bool:
	if not has_save():
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		return false

	var data = JSON.parse_string(file.get_as_text())
	file.close()

	if not data is Dictionary:
		return false

	current_day = int(data.get("current_day", 1))
	citations = int(data.get("citations", 0))
	public_trust = int(data.get("public_trust", 50))

	return true


func complete_day() -> void:
	current_day += 1
	save_game()
