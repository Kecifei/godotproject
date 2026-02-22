extends Node

var _ui_player: AudioStreamPlayer
var _notification_player: AudioStreamPlayer

func _ready() -> void:
	_ui_player = AudioStreamPlayer.new()
	_notification_player = AudioStreamPlayer.new()
	add_child(_ui_player)
	add_child(_notification_player)

func play_ui_click() -> void:
	if _ui_player.stream != null:
		_ui_player.play()

func play_notification() -> void:
	if _notification_player.stream != null:
		_notification_player.play()
