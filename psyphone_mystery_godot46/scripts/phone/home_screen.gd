extends Control

signal request_open_app(app_id: String)

const AppIconScene = preload("res://scenes/ui/components/AppIcon.tscn")

@onready var app_grid: GridContainer = $MarginContainer/AppGrid

var _badge_by_app: Dictionary = {}

func _ready() -> void:
	State.app_unlocked.connect(_on_app_unlocked)
	_build_grid()

func _build_grid() -> void:
	for child in app_grid.get_children():
		child.queue_free()
	for app in Content.get_apps_registry():
		var app_id: String = String(app.get("id", ""))
		if app_id.is_empty() or not State.is_app_unlocked(app_id):
			continue
		var icon := AppIconScene.instantiate()
		icon.app_id = app_id
		icon.app_name = String(app.get("name", app_id.capitalize()))
		var icon_path: String = String(app.get("icon", ""))
		if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
			icon.icon_texture = load(icon_path)
		if icon.has_signal("open_requested"):
			icon.open_requested.connect(_on_icon_open_requested)
		if icon.has_method("set_badge_count"):
			icon.call("set_badge_count", int(_badge_by_app.get(app_id, 0)))
		app_grid.add_child(icon)

func _on_icon_open_requested(app_id: String) -> void:
	Audio.play_ui_click()
	request_open_app.emit(app_id)

func set_badge(app_id: String, count: int) -> void:
	_badge_by_app[app_id] = count
	for child in app_grid.get_children():
		if child.has_method("get_app_id") and child.get_app_id() == app_id:
			if child.has_method("set_badge_count"):
				child.call("set_badge_count", count)
			return

func _on_app_unlocked(_app_id: String) -> void:
	_build_grid()
