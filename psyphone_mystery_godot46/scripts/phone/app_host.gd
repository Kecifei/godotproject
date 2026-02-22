extends Control

signal app_opened(app_id: String)
signal app_closed

@onready var _container: Control = $AppContainer

var _current_app_id: String = ""
var _current_app: Node = null
var _nav_stack: Array[Control] = []

func open_app(app_id: String, params := {}) -> void:
	_clear_current_app()
	_current_app_id = app_id
	var scene_path: String = Content.get_app_scene(app_id)
	if scene_path.is_empty():
		push_error("Unknown app id: %s" % app_id)
		return
	var packed: PackedScene = load(scene_path)
	if packed == null:
		push_error("Unable to load app scene: %s" % scene_path)
		return
	_current_app = packed.instantiate()
	_container.add_child(_current_app)
	if _current_app.has_signal("request_back"):
		_current_app.connect("request_back", Callable(self, "_on_app_request_back"))
	if _current_app.has_method("on_opened"):
		_current_app.call("on_opened", params)
	app_opened.emit(app_id)

func push_view(scene: PackedScene) -> Control:
	var view := scene.instantiate() as Control
	if view == null:
		push_error("push_view expected a Control scene.")
		return null
	if _container.get_child_count() > 0 and _container.get_child(0) is Control:
		var current_view := _container.get_child(0) as Control
		current_view.visible = false
		_nav_stack.append(current_view)
	_container.add_child(view)
	return view

func pop_view() -> void:
	#region agent log
	_agent_log("baseline", "H2", "scripts/phone/app_host.gd:pop_view", "Pop view requested", {"stack_size_before": _nav_stack.size(), "children_before": _container.get_child_count()})
	#endregion
	if _container.get_child_count() > 0:
		var top := _container.get_child(_container.get_child_count() - 1)
		top.queue_free()
	if _nav_stack.is_empty():
		_clear_current_app()
		app_closed.emit()
		return
	var restored: Control = _nav_stack.pop_back() as Control
	if restored == null:
		#region agent log
		_agent_log("baseline", "H2", "scripts/phone/app_host.gd:pop_view", "Restored view is null", {"stack_size_after_pop": _nav_stack.size()})
		#endregion
		push_error("AppHost nav stack pop returned null.")
		return
	if is_instance_valid(restored):
		restored.visible = true
		#region agent log
		_agent_log("baseline", "H2", "scripts/phone/app_host.gd:pop_view", "Restored view made visible", {"stack_size_after_pop": _nav_stack.size()})
		#endregion

func close_app() -> void:
	_clear_current_app()
	app_closed.emit()

func has_open_app() -> bool:
	return _current_app != null and is_instance_valid(_current_app)

func _on_app_request_back() -> void:
	close_app()

func _clear_current_app() -> void:
	for child in _container.get_children():
		child.queue_free()
	_current_app = null
	_current_app_id = ""
	_nav_stack.clear()

#region agent log
func _agent_log(run_id: String, hypothesis_id: String, location: String, message: String, data: Dictionary = {}) -> void:
	var payload: Dictionary = {
		"runId": run_id,
		"hypothesisId": hypothesis_id,
		"location": location,
		"message": message,
		"data": data,
		"timestamp": Time.get_unix_time_from_system() * 1000
	}
	var file := FileAccess.open("c:/Users/mrtom/Desktop/godotpr/.cursor/debug.log", FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open("c:/Users/mrtom/Desktop/godotpr/.cursor/debug.log", FileAccess.WRITE)
	if file != null:
		file.seek_end()
		file.store_line(JSON.stringify(payload))
#endregion
