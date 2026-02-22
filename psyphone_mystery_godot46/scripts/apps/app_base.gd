extends Control

signal request_back

@onready var back_button: Button = $VBox/Header/BackButton
@onready var title_label: Label = $VBox/Header/TitleLabel
@onready var content_slot: Control = $VBox/ContentSlot

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func set_title(text: String) -> void:
	title_label.text = text

func set_content(node: Control) -> void:
	for child in content_slot.get_children():
		child.queue_free()
	content_slot.add_child(node)

func _on_back_pressed() -> void:
	Audio.play_ui_click()
	request_back.emit()
