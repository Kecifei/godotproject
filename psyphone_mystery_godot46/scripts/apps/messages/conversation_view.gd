extends Control

signal request_back

@onready var back_button: Button = $VBox/ThreadHeader/BackToThreadsButton
@onready var title_label: Label = $VBox/ThreadHeader/ThreadTitle
@onready var scroll: ScrollContainer = $VBox/Scroll
@onready var messages_box: VBoxContainer = $VBox/Scroll/MessagesBox

var _thread_id: String = ""
var _reported_done: bool = false

func _ready() -> void:
	back_button.pressed.connect(func(): request_back.emit())
	_build()

func setup(thread_id: String) -> void:
	_thread_id = thread_id

func _process(_delta: float) -> void:
	if _reported_done:
		return
	var bar := scroll.get_v_scroll_bar()
	if bar.max_value <= 0.0:
		return
	if bar.value >= bar.max_value - 24.0:
		_report_thread_read_done()

func _build() -> void:
	if _thread_id.is_empty():
		return
	var thread: Dictionary = Content.get_thread(_thread_id)
	title_label.text = String(thread.get("title", _thread_id))
	for child in messages_box.get_children():
		child.queue_free()
	var messages: Array = thread.get("messages", [])
	for message in messages:
		if not (message is Dictionary):
			continue
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "[%s] %s: %s" % [
			String(message.get("timestamp", "")),
			String(message.get("sender", "Unknown")),
			String(message.get("text", ""))
		]
		messages_box.add_child(label)
	await get_tree().process_frame
	scroll.scroll_vertical = 0

func _report_thread_read_done() -> void:
	_reported_done = true
	Notifications.set_badge("messages", 0)
	Events.report_action("messages_thread_read_done", {"thread_id": _thread_id})
