extends Node

var fired_events: Dictionary = {}
var _event_defs: Array[Dictionary] = []

func bootstrap() -> void:
	_event_defs = Content.get_story_events()
	#region agent log
	_agent_log("baseline", "H3", "scripts/managers/events.gd:bootstrap", "Events bootstrapped", {"event_defs_count": _event_defs.size()})
	#endregion
	_evaluate_for_trigger("boot", "", {})

func report_action(action_id: String, payload := {}) -> void:
	#region agent log
	_agent_log("baseline", "H3", "scripts/managers/events.gd:report_action", "Action reported", {"action_id": action_id, "payload": payload})
	#endregion
	State.record_action(action_id, payload)
	_evaluate_for_trigger("action", action_id, payload)

func evaluate_all() -> void:
	_evaluate_for_trigger("any", "", {})

func _evaluate_for_trigger(trigger: String, action_id: String, payload: Dictionary) -> void:
	for event_data in _event_defs:
		var event_id: String = String(event_data.get("id", ""))
		if event_id.is_empty():
			continue
		if fired_events.has(event_id):
			continue
		var event_on: String = String(event_data.get("on", "action"))
		if trigger != "any" and event_on != trigger:
			continue
		if event_on == "action":
			var expected_action: String = String(event_data.get("action_id", ""))
			if not expected_action.is_empty() and expected_action != action_id:
				continue
		var condition: Dictionary = event_data.get("condition", {})
		if not _condition_met(condition, action_id, payload):
			continue
		_execute_actions(event_data.get("actions", []))
		fired_events[event_id] = true

func _condition_met(condition: Dictionary, _action_id: String, _payload: Dictionary) -> bool:
	if condition.is_empty():
		return true
	var kind: String = String(condition.get("type", ""))
	match kind:
		"flag_true":
			return State.has_flag(String(condition.get("flag_id", "")))
		"app_unlocked":
			return State.is_app_unlocked(String(condition.get("app_id", "")))
		"action_occurred":
			var expected_action: String = String(condition.get("action_id", ""))
			if State.get_action_count(expected_action) <= 0:
				return false
			if condition.has("thread_id"):
				var last_payload: Dictionary = State.get_last_action_payload(expected_action)
				return String(last_payload.get("thread_id", "")) == String(condition.get("thread_id", ""))
			return true
		"time_after_minutes":
			return TimeSim.now_minutes >= int(condition.get("value", 0))
		_:
			push_error("Unknown condition type: %s" % kind)
			return false

func _execute_actions(actions: Array) -> void:
	for action in actions:
		if not (action is Dictionary):
			continue
		var action_type: String = String(action.get("type", ""))
		match action_type:
			"unlock_app":
				var app_id: String = String(action.get("app_id", ""))
				State.unlock_app(app_id)
				if action.has("toast"):
					Notifications.push_toast(String(action.get("toast", "")))
				if action.has("badge"):
					Notifications.increment_badge(app_id, int(action.get("badge", 1)))
			"set_flag":
				State.set_flag(String(action.get("flag_id", "")), bool(action.get("value", true)))
			"toast":
				Notifications.push_toast(String(action.get("text", "")))
			"badge_increment":
				Notifications.increment_badge(String(action.get("app_id", "")), int(action.get("delta", 1)))
			"schedule_action":
				TimeSim.schedule_in_minutes(
					int(action.get("minutes_from_now", 0)),
					String(action.get("action_id", "")),
					action.get("payload", {})
				)
			"send_message_notification":
				Notifications.increment_badge("messages", 1)
				Notifications.push_toast(String(action.get("text", "New message.")))
			_:
				push_error("Unknown action type: %s" % action_type)

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
