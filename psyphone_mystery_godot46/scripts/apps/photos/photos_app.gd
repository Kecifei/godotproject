extends Control

signal request_back

const ImageViewerScene = preload("res://scenes/apps/photos/ImageViewer.tscn")

@onready var app_base: Control = $AppBase

func _ready() -> void:
	app_base.set_title("Photos")
	app_base.request_back.connect(func(): request_back.emit())
	_show_index()

func _show_index() -> void:
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for photo in Content.get_photos_index():
		var photo_id: String = String(photo.get("id", ""))
		var title: String = String(photo.get("title", photo_id))
		var button := Button.new()
		button.text = title
		button.custom_minimum_size = Vector2(0, 64)
		button.pressed.connect(_open_photo.bind(photo))
		list.add_child(button)
	app_base.set_content(list)

func _open_photo(photo: Dictionary) -> void:
	Audio.play_ui_click()
	var viewer := ImageViewerScene.instantiate()
	viewer.setup(photo)
	viewer.request_back.connect(_show_index)
	app_base.set_content(viewer)
