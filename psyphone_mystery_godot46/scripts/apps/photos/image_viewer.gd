extends Control

signal request_back

@onready var back_button: Button = $VBox/Header/BackButton
@onready var inspect_button: Button = $VBox/Header/InspectButton
@onready var title_label: Label = $VBox/Header/TitleLabel
@onready var photo_rect: TextureRect = $VBox/PhotoArea/PhotoRect

var _photo_id: String = ""
var _zoom: float = 1.0
var _dragging: bool = false
var _drag_last_pos: Vector2 = Vector2.ZERO
var _reported_inspect: bool = false

func _ready() -> void:
	back_button.pressed.connect(func(): request_back.emit())
	inspect_button.pressed.connect(_report_inspection)
	_update_transform()

func setup(photo: Dictionary) -> void:
	_photo_id = String(photo.get("id", "photo_001"))
	title_label.text = String(photo.get("title", _photo_id))
	var path: String = String(photo.get("image_path", ""))
	if not path.is_empty() and ResourceLoader.exists(path):
		photo_rect.texture = load(path)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_event.pressed:
			_zoom = minf(_zoom + 0.1, 3.0)
			_update_transform()
		elif mouse_event.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_event.pressed:
			_zoom = maxf(_zoom - 0.1, 0.5)
			_update_transform()
		elif mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = mouse_event.pressed
			_drag_last_pos = mouse_event.position
	elif event is InputEventMouseMotion and _dragging:
		var motion := event as InputEventMouseMotion
		photo_rect.position += motion.relative

	if _zoom >= 2.2 and not _reported_inspect:
		_report_inspection()

func _update_transform() -> void:
	photo_rect.scale = Vector2.ONE * _zoom

func _report_inspection() -> void:
	if _reported_inspect:
		return
	_reported_inspect = true
	Events.report_action("photo_inspected_burn_mark", {"photo_id": _photo_id})
	Notifications.push_toast("Burn mark inspected.")
