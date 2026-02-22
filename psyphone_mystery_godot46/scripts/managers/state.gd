extends Node

signal flag_changed(flag_id: String, value: bool)
signal app_unlocked(app_id: String)

var flags: Dictionary = {}
var unlocked_apps: Dictionary = {}
var discovered_items: Dictionary = {}
var action_history: Dictionary = {}

func set_flag(flag_id: String, value := true) -> void:
	var old_value: bool = bool(flags.get(flag_id, false))
	flags[flag_id] = bool(value)
	if old_value != bool(value):
		flag_changed.emit(flag_id, bool(value))

func has_flag(flag_id: String) -> bool:
	return bool(flags.get(flag_id, false))

func unlock_app(app_id: String) -> void:
	if is_app_unlocked(app_id):
		return
	unlocked_apps[app_id] = true
	app_unlocked.emit(app_id)

func is_app_unlocked(app_id: String) -> bool:
	return bool(unlocked_apps.get(app_id, false))

func mark_discovered(item_id: String) -> void:
	discovered_items[item_id] = true

func is_discovered(item_id: String) -> bool:
	return bool(discovered_items.get(item_id, false))

func record_action(action_id: String, payload := {}) -> void:
	var current: Dictionary = action_history.get(action_id, {"count": 0, "last_payload": {}})
	current["count"] = int(current.get("count", 0)) + 1
	current["last_payload"] = payload.duplicate(true)
	action_history[action_id] = current

func get_action_count(action_id: String) -> int:
	var current: Dictionary = action_history.get(action_id, {})
	return int(current.get("count", 0))

func get_last_action_payload(action_id: String) -> Dictionary:
	var current: Dictionary = action_history.get(action_id, {})
	return current.get("last_payload", {})
