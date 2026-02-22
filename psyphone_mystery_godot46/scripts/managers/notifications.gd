extends Node

signal toast_queued(text: String)
signal badge_changed(app_id: String, count: int)

var _badges: Dictionary = {}

func push_toast(text: String) -> void:
	toast_queued.emit(text)

func set_badge(app_id: String, count: int) -> void:
	var clamped: int = maxi(0, count)
	_badges[app_id] = clamped
	badge_changed.emit(app_id, clamped)

func increment_badge(app_id: String, delta := 1) -> void:
	set_badge(app_id, get_badge(app_id) + int(delta))

func get_badge(app_id: String) -> int:
	return int(_badges.get(app_id, 0))
