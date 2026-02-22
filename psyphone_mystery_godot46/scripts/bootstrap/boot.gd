extends Node

func _ready() -> void:
	#region agent log
	_agent_log("baseline", "H4", "scripts/bootstrap/boot.gd:_ready", "Boot ready entered", {})
	#endregion
	Content.load_all()
	#region agent log
	_agent_log("baseline", "H5", "scripts/bootstrap/boot.gd:_ready", "Content loaded", {})
	#endregion
	Save.load_or_create()
	#region agent log
	_agent_log("baseline", "H5", "scripts/bootstrap/boot.gd:_ready", "Save loaded/created", {})
	#endregion
	Events.bootstrap()
	#region agent log
	_agent_log("baseline", "H5", "scripts/bootstrap/boot.gd:_ready", "Events bootstrapped", {})
	#endregion
	get_tree().call_deferred("change_scene_to_file", "res://scenes/phone/PhoneRoot.tscn")
	#region agent log
	_agent_log("baseline", "H6", "scripts/bootstrap/boot.gd:_ready", "Deferred scene change to PhoneRoot", {})
	#endregion

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
