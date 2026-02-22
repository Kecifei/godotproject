extends Node

const Validate = preload("res://scripts/systems/util/validate.gd")

var _apps: Array[Dictionary] = []
var _threads_index: Array[Dictionary] = []
var _thread_by_id: Dictionary = {}
var _story_events: Array[Dictionary] = []
var _photos_index: Array[Dictionary] = []

func load_all() -> void:
	_apps = _load_json_array("res://data/json/apps.json")
	_threads_index = _load_json_array("res://data/json/messages/threads.json")
	_story_events = _load_json_array("res://data/json/story_events.json")
	_photos_index = _load_json_array("res://data/json/photos/photos_index.json")
	#region agent log
	_agent_log(
		"baseline",
		"H5",
		"scripts/managers/content.gd:load_all",
		"Loaded primary content registries",
		{
			"apps_count": _apps.size(),
			"threads_count": _threads_index.size(),
			"story_events_count": _story_events.size(),
			"photos_count": _photos_index.size()
		}
	)
	#endregion

	_thread_by_id.clear()
	for thread_entry in _threads_index:
		var thread_id: String = String(thread_entry.get("id", ""))
		if thread_id.is_empty():
			_fail_critical("messages/threads.json has thread without id.")
		var path: String = "res://data/json/messages/%s.json" % thread_id
		var thread_data: Dictionary = _load_json_dict(path)
		_thread_by_id[thread_id] = thread_data

	if OS.is_debug_build():
		var validation_errors: PackedStringArray = Validate.validate_content(_apps, _story_events)
		for message in validation_errors:
			push_error(message)
		assert(validation_errors.is_empty(), "Content validation failed.")

	_apply_default_unlocks()

func get_apps_registry() -> Array[Dictionary]:
	return _apps.duplicate(true)

func get_app_scene(app_id: String) -> String:
	for app in _apps:
		if String(app.get("id", "")) == app_id:
			return String(app.get("scene", ""))
	return ""

func get_message_threads() -> Array[Dictionary]:
	return _threads_index.duplicate(true)

func get_thread(thread_id: String) -> Dictionary:
	return _thread_by_id.get(thread_id, {}).duplicate(true)

func get_story_events() -> Array[Dictionary]:
	return _story_events.duplicate(true)

func get_photos_index() -> Array[Dictionary]:
	return _photos_index.duplicate(true)

func _apply_default_unlocks() -> void:
	for app in _apps:
		if bool(app.get("default_unlocked", false)):
			State.unlock_app(String(app.get("id", "")))

func _load_json_array(path: String) -> Array[Dictionary]:
	var parsed: Variant = _load_json(path)
	if not (parsed is Array):
		_fail_critical("%s must be a JSON array." % path)
	var output: Array[Dictionary] = []
	for item in parsed:
		if not (item is Dictionary):
			_fail_critical("%s contains non-object element." % path)
		output.append(item)
	return output

func _load_json_dict(path: String) -> Dictionary:
	var parsed: Variant = _load_json(path)
	if not (parsed is Dictionary):
		_fail_critical("%s must be a JSON object." % path)
	return parsed

func _load_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		_fail_critical("Missing JSON file: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail_critical("Could not open JSON file: %s" % path)
	var text: String = file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		_fail_critical("Invalid JSON in file: %s" % path)
	return parsed

func _fail_critical(message: String) -> void:
	push_error(message)
	#region agent log
	_agent_log("baseline", "H5", "scripts/managers/content.gd:_fail_critical", "Content critical failure", {"error": message})
	#endregion
	if OS.is_debug_build():
		assert(false, message)

#region agent log
func _agent_log(run_id: String, hypothesis_id: String, location: String, message: String, data: Dictionary = {}) -> void:
	var payload: Dictionary = {
		"runId": run_id,
		"hypothesisId": hypothesis_id,
		"location": location,
		"message": message,
		"data": data,
		"timestamp": Time.get_unix_time_from_system() * 1000
	}
	var file := FileAccess.open("c:/Users/mrtom/Desktop/godotpr/.cursor/debug.log", FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open("c:/Users/mrtom/Desktop/godotpr/.cursor/debug.log", FileAccess.WRITE)
	if file != null:
		file.seek_end()
		file.store_line(JSON.stringify(payload))
#endregion
