extends Node

signal minute_changed(now_minutes: int)

@export var real_seconds_per_sim_minute: float = 1.0

var now_minutes: int = 0
var _running: bool = true
var _accumulated: float = 0.0
var _scheduled: Array[Dictionary] = []

func _ready() -> void:
	set_process(true)

func start() -> void:
	_running = true

func pause() -> void:
	_running = false

func _process(delta: float) -> void:
	if not _running:
		return
	_accumulated += delta
	while _accumulated >= real_seconds_per_sim_minute:
		_accumulated -= real_seconds_per_sim_minute
		now_minutes += 1
		minute_changed.emit(now_minutes)
		_process_due_schedules()

func schedule_in_minutes(minutes_from_now: int, action_id: String, payload := {}) -> void:
	var due_minutes: int = now_minutes + maxi(0, minutes_from_now)
	_scheduled.append({
		"due_minutes": due_minutes,
		"action_id": action_id,
		"payload": payload.duplicate(true)
	})

func get_scheduled() -> Array[Dictionary]:
	return _scheduled.duplicate(true)

func set_scheduled(new_scheduled: Array) -> void:
	_scheduled.clear()
	for entry in new_scheduled:
		if entry is Dictionary:
			_scheduled.append(entry.duplicate(true))

func _process_due_schedules() -> void:
	var remaining: Array[Dictionary] = []
	for entry in _scheduled:
		var due: int = int(entry.get("due_minutes", 0))
		if due <= now_minutes:
			var action_id: String = String(entry.get("action_id", ""))
			var payload: Dictionary = entry.get("payload", {})
			Events.report_action(action_id, payload)
		else:
			remaining.append(entry)
	_scheduled = remaining
