extends Control

signal request_back

const ConversationScene = preload("res://scenes/apps/messages/ConversationView.tscn")

@onready var app_base: Control = $AppBase

func _ready() -> void:
	app_base.set_title("Messages")
	app_base.request_back.connect(func(): request_back.emit())
	_show_threads()

func _show_threads() -> void:
	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for thread in Content.get_message_threads():
		var thread_id: String = String(thread.get("id", ""))
		var title: String = String(thread.get("title", thread_id))
		var preview: String = String(thread.get("preview", ""))
		var button := Button.new()
		button.text = "%s\n%s" % [title, preview]
		button.custom_minimum_size = Vector2(0, 72)
		button.pressed.connect(_open_thread.bind(thread_id))
		root.add_child(button)
	app_base.set_content(root)

func _open_thread(thread_id: String) -> void:
	Audio.play_ui_click()
	var convo := ConversationScene.instantiate()
	convo.setup(thread_id)
	convo.request_back.connect(_show_threads)
	app_base.set_content(convo)
