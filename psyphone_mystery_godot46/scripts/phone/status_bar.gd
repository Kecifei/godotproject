extends Control

@onready var time_label: Label = $HBox/TimeLabel
@onready var notif_dot: Label = $HBox/NotifDot

func _ready() -> void:
	#region agent log
	_agent_log("post-fix", "H8", "scripts/phone/status_bar.gd:_ready", "StatusBar ready entered", {"now_minutes": TimeSim.now_minutes})
	#endregion
	Notifications.badge_changed.connect(_on_badge_changed)
	set_time_minutes(TimeSim.now_minutes)
	_refresh_dot()

func set_time_minutes(now_minutes: int) -> void:
	#region agent log
	_agent_log("post-fix", "H8", "scripts/phone/status_bar.gd:set_time_minutes", "set_time_minutes called", {"now_minutes": now_minutes})
	#endregion
	var total: int = now_minutes % (24 * 60)
	var hours: int = int(total / 60.0)
	var minutes: int = total % 60
	time_label.text = "%02d:%02d" % [hours, minutes]

func _on_badge_changed(_app_id: String, _count: int) -> void:
	_refresh_dot()

func _refresh_dot() -> void:
	var has_any := false
	for app in Content.get_apps_registry():
		var app_id: String = String(app.get("id", ""))
		if Notifications.get_badge(app_id) > 0:
			has_any = true
			break
	notif_dot.visible = has_any

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
