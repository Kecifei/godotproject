extends Node

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1

var _save_timer: SceneTreeTimer
var _is_loaded: bool = false

func _ready() -> void:
	State.flag_changed.connect(_queue_save)
	State.app_unlocked.connect(_on_app_unlocked)

func load_or_create() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_now()
		_is_loaded = true
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open save file. Creating a new one.")
		_reset_state()
		save_now()
		_is_loaded = true
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_error("Save file invalid. Resetting state.")
		_reset_state()
		save_now()
		_is_loaded = true
		return
	var save_dict: Dictionary = parsed
	if int(save_dict.get("save_version", -1)) != SAVE_VERSION:
		push_error("Save version mismatch. Resetting state (migration stub).")
		_reset_state()
		save_now()
		_is_loaded = true
		return
	_load_from_dict(save_dict)
	_is_loaded = true

func save_now() -> void:
	var payload: Dictionary = {
		"save_version": SAVE_VERSION,
		"state": {
			"flags": State.flags,
			"unlocked_apps": State.unlocked_apps,
			"discovered_items": State.discovered_items,
			"action_history": State.action_history
		},
		"time": {
			"now_minutes": TimeSim.now_minutes,
			"scheduled": TimeSim.get_scheduled()
		},
		"events": {
			"fired_events": Events.fired_events
		}
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not open save file for writing.")
		return
	file.store_string(JSON.stringify(payload, "\t"))

func _queue_save(_arg1 = null, _arg2 = null) -> void:
	if not _is_loaded:
		return
	if _save_timer != null:
		return
	_save_timer = get_tree().create_timer(0.5)
	_save_timer.timeout.connect(_flush_queued_save)

func _flush_queued_save() -> void:
	_save_timer = null
	save_now()

func _on_app_unlocked(_app_id: String) -> void:
	_queue_save()

func _load_from_dict(save_dict: Dictionary) -> void:
	var state_dict: Dictionary = save_dict.get("state", {})
	State.flags = state_dict.get("flags", {})
	State.unlocked_apps = state_dict.get("unlocked_apps", {})
	State.discovered_items = state_dict.get("discovered_items", {})
	State.action_history = state_dict.get("action_history", {})

	var time_dict: Dictionary = save_dict.get("time", {})
	TimeSim.now_minutes = int(time_dict.get("now_minutes", 0))
	TimeSim.set_scheduled(time_dict.get("scheduled", []))

	var events_dict: Dictionary = save_dict.get("events", {})
	Events.fired_events = events_dict.get("fired_events", {})

func _reset_state() -> void:
	State.flags = {}
	State.unlocked_apps = {}
	State.discovered_items = {}
	State.action_history = {}
	TimeSim.now_minutes = 0
	TimeSim.set_scheduled([])
	Events.fired_events = {}
