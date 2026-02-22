extends Button

signal open_requested(app_id: String)

@export var app_id: String = ""
@export var app_name: String = ""
@export var icon_texture: Texture2D

@onready var icon_rect: TextureRect = $VBox/Icon
@onready var name_label: Label = $VBox/Name
@onready var badge_label: Label = $Badge
var _pending_badge_count: int = 0

func _ready() -> void:
	pressed.connect(_on_pressed)
	_refresh()
	#region agent log
	_agent_log("post-fix", "H7", "scripts/phone/app_icon.gd:_ready", "AppIcon ready", {"app_id": app_id, "badge_label_ready": badge_label != null, "pending_badge": _pending_badge_count})
	#endregion
	set_badge_count(_pending_badge_count)

func _refresh() -> void:
	name_label.text = app_name
	icon_rect.texture = icon_texture

func set_badge_count(count: int) -> void:
	_pending_badge_count = count
	if badge_label == null:
		#region agent log
		_agent_log("post-fix", "H7", "scripts/phone/app_icon.gd:set_badge_count", "Badge label not ready yet", {"app_id": app_id, "count": count})
		#endregion
		return
	badge_label.visible = count > 0
	badge_label.text = str(count)
	#region agent log
	_agent_log("post-fix", "H7", "scripts/phone/app_icon.gd:set_badge_count", "Badge applied", {"app_id": app_id, "count": count})
	#endregion

func get_app_id() -> String:
	return app_id

func _on_pressed() -> void:
	open_requested.emit(app_id)

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
