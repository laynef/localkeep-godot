@tool
extends EditorPlugin

const SageDock = preload("res://addons/sage_ai/sage_dock.tscn")
var _dock: Control

func _enter_tree() -> void:
	_dock = SageDock.instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_BL, _dock)
	add_tool_menu_item("Sage: Explain Script", _explain_current_script)
	add_tool_menu_item("Sage: Generate GUT Tests", _generate_tests)
	add_tool_menu_item("Sage: List Models", _list_models)

func _exit_tree() -> void:
	if _dock:
		remove_control_from_docks(_dock)
		_dock.free()
	remove_tool_menu_item("Sage: Explain Script")
	remove_tool_menu_item("Sage: Generate GUT Tests")
	remove_tool_menu_item("Sage: List Models")

func _explain_current_script() -> void:
	var script = get_editor_interface().get_script_editor().get_current_script()
	if script == null:
		push_warning("Sage: Open a script first")
		return
	var path := ProjectSettings.globalize_path(script.resource_path)
	_dock.run_task_with_file(path, "Explain this Godot 4 GDScript file clearly. Describe what it does, key variables, and how it fits into a game project.")

func _generate_tests() -> void:
	var script = get_editor_interface().get_script_editor().get_current_script()
	if script == null:
		push_warning("Sage: Open a script first")
		return
	var path := ProjectSettings.globalize_path(script.resource_path)
	_dock.run_task_with_file(path, "Generate GUT (Godot Unit Testing) tests for this GDScript. Include tests for public methods, signals, and edge cases.")

func _list_models() -> void:
	_dock.list_models()
