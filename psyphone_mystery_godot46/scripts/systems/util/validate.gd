extends RefCounted

static func validate_content(apps: Array, story_events: Array) -> PackedStringArray:
	var errors: PackedStringArray = []
	var app_ids: Dictionary = {}
	for app in apps:
		if not (app is Dictionary):
			errors.append("apps.json contains non-dictionary entry.")
			continue
		var app_id: String = String(app.get("id", ""))
		var scene_path: String = String(app.get("scene", ""))
		if app_id.is_empty():
			errors.append("apps.json entry missing id.")
		else:
			app_ids[app_id] = true
		if scene_path.is_empty():
			errors.append("app '%s' missing scene path." % app_id)
		elif not ResourceLoader.exists(scene_path):
			errors.append("app '%s' scene does not exist: %s" % [app_id, scene_path])

	var known_actions: Dictionary = {
		"messages_thread_read_done": true,
		"photo_inspected_burn_mark": true,
		"scheduled_new_message": true
	}
	for event_data in story_events:
		if not (event_data is Dictionary):
			errors.append("story_events.json contains non-dictionary entry.")
			continue
		var event_id: String = String(event_data.get("id", "unknown"))
		var condition: Dictionary = event_data.get("condition", {})
		var condition_type: String = String(condition.get("type", ""))
		if condition_type == "action_occurred":
			var condition_action_id: String = String(condition.get("action_id", ""))
			if condition_action_id.is_empty() or not known_actions.has(condition_action_id):
				errors.append("event '%s' condition references unknown action '%s'." % [event_id, condition_action_id])
		elif condition_type == "app_unlocked":
			var condition_app_id: String = String(condition.get("app_id", ""))
			if condition_app_id.is_empty() or not app_ids.has(condition_app_id):
				errors.append("event '%s' condition references unknown app '%s'." % [event_id, condition_app_id])
		var actions: Array = event_data.get("actions", [])
		if not (actions is Array):
			errors.append("event '%s' has invalid actions array." % event_id)
			continue
		for action in actions:
			if not (action is Dictionary):
				errors.append("event '%s' has non-dictionary action." % event_id)
				continue
			var action_type: String = String(action.get("type", ""))
			if action_type == "unlock_app":
				var app_id: String = String(action.get("app_id", ""))
				if app_id.is_empty() or not app_ids.has(app_id):
					errors.append("event '%s' unlock_app references unknown app '%s'." % [event_id, app_id])
			elif action_type == "schedule_action":
				var action_id: String = String(action.get("action_id", ""))
				if action_id.is_empty() or not known_actions.has(action_id):
					errors.append("event '%s' schedule_action references unknown action '%s'." % [event_id, action_id])
	return errors
