extends Control

const ToastScene = preload("res://scenes/ui/components/NotificationToast.tscn")

@onready var status_bar: Control = $SafeArea/StatusBar
@onready var home_screen: Control = $SafeArea/HomeScreen
@onready var app_host: Control = $SafeArea/AppHost
@onready var toasts_layer: CanvasLayer = $ToastsLayer

func _ready() -> void:
	Notifications.toast_queued.connect(_on_toast_queued)
	Notifications.badge_changed.connect(_on_badge_changed)
	TimeSim.minute_changed.connect(_on_minute_changed)
	app_host.app_opened.connect(_on_app_opened)
	app_host.app_closed.connect(_on_app_closed)
	home_screen.request_open_app.connect(_on_home_request_open_app)
	_on_minute_changed(TimeSim.now_minutes)
	_update_home_visibility()

func _on_home_request_open_app(app_id: String) -> void:
	app_host.open_app(app_id)

func _on_toast_queued(text: String) -> void:
	var toast := ToastScene.instantiate()
	toasts_layer.add_child(toast)
	toast.show_toast(text, 2.5)
	Audio.play_notification()

func _on_badge_changed(app_id: String, count: int) -> void:
	if home_screen.has_method("set_badge"):
		home_screen.call("set_badge", app_id, count)

func _on_minute_changed(now_minutes: int) -> void:
	if status_bar.has_method("set_time_minutes"):
		status_bar.call("set_time_minutes", now_minutes)

func _on_app_opened(_app_id: String) -> void:
	_update_home_visibility()

func _on_app_closed() -> void:
	_update_home_visibility()

func _update_home_visibility() -> void:
	home_screen.visible = not app_host.has_open_app()
