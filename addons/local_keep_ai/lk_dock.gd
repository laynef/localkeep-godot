@tool
extends Control

@onready var _output: RichTextLabel = $VBox/Output
@onready var _input: LineEdit       = $VBox/InputRow/Input
@onready var _send_btn: Button      = $VBox/InputRow/SendBtn
@onready var _model_label: Label    = $VBox/Header/ModelLabel

func _ready() -> void:
	_model_label.text = "Model: " + LocalKeepClient.read_default_model()
	_send_btn.pressed.connect(_on_send)
	_input.text_submitted.connect(func(_t): _on_send())
	_output.bbcode_enabled = true

func _on_send() -> void:
	var task := _input.text.strip_edges()
	if task == "":
		return
	_input.text = ""
	var model := LocalKeepClient.read_default_model()
	_append("[b]You:[/b] " + task)

	var args := PackedStringArray(["ask", "--model", model, "--raw", task])
	_append("[color=#888]⟡ Asking " + model + "...[/color]")

	LocalKeepClient.run_async(args, ProjectSettings.globalize_path("res://"),
		func(code: int, output: String):
			if code == 0:
				_append("[b]LocalKeep:[/b]\n" + output.strip_edges())
			else:
				_append("[color=red]Error (code " + str(code) + "):[/color]\n" + output)
	)

func run_task_with_file(file_path: String, instruction: String) -> void:
	var model := LocalKeepClient.read_default_model()
	_append("[b]LocalKeep:[/b] Analyzing " + file_path.get_file() + "...")
	var args := PackedStringArray(["ask", "--model", model, "--file", file_path, instruction])
	LocalKeepClient.run_async(args, file_path.get_base_dir(),
		func(code: int, output: String):
			if code == 0:
				_append(output.strip_edges())
			else:
				_append("[color=red]Error:[/color] " + output)
	)

func list_models() -> void:
	_append("[b]Fetching models...[/b]")
	LocalKeepClient.run_async(PackedStringArray(["models", "--all"]),
		ProjectSettings.globalize_path("res://"),
		func(_code: int, output: String):
			_append("[b]Available models:[/b]\n" + output.strip_edges())
	)

func _append(text: String) -> void:
	call_deferred("_append_deferred", text)

func _append_deferred(text: String) -> void:
	_output.append_text(text + "\n\n")
	_output.scroll_to_line(_output.get_line_count())
