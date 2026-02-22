extends PanelContainer

@onready var label: Label = $Label

func show_toast(text: String, duration_sec := 2.5) -> void:
	label.text = text
	var timer := get_tree().create_timer(duration_sec)
	timer.timeout.connect(queue_free)
