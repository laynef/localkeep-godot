@tool
class_name SageClient
extends RefCounted

const CANDIDATE_PATHS := [
	"/opt/homebrew/bin/sage",
	"/usr/local/bin/sage",
]

static func find_binary() -> String:
	# Check HOME/.local/bin/sage
	var home := OS.get_environment("HOME")
	var local_bin := home + "/.local/bin/sage"
	if FileAccess.file_exists(local_bin):
		return local_bin
	# Check candidate paths
	for p in CANDIDATE_PATHS:
		if FileAccess.file_exists(p):
			return p
	# Try `which sage`
	var output := []
	OS.execute("which", ["sage"], output, true)
	var result: String = output[0].strip_edges() if output.size() > 0 else ""
	if result != "" and FileAccess.file_exists(result):
		return result
	return ""

static func read_default_model() -> String:
	var home := OS.get_environment("HOME")
	var cfg_path := home + "/.sage/config.json"
	if not FileAccess.file_exists(cfg_path):
		return "cloud:qwen3-coder"
	var f := FileAccess.open(cfg_path, FileAccess.READ)
	if not f:
		return "cloud:qwen3-coder"
	var text := f.get_as_text()
	f.close()
	var json := JSON.new()
	if json.parse(text) == OK:
		var data = json.data
		if data is Dictionary and data.has("default_model"):
			return str(data["default_model"])
	return "cloud:qwen3-coder"

# Run sage synchronously in a thread. callback(exit_code: int, output: String)
static func run_async(args: PackedStringArray, cwd: String, callback: Callable) -> void:
	var binary := find_binary()
	if binary == "":
		callback.call(-1, "sage not found.\nInstall: pip install sage-ai-cli && sage login")
		return
	var full_args := PackedStringArray([binary])
	full_args.append_array(args)

	# Thread stored in Engine metadata to prevent GC before completion
	var thread := Thread.new()
	Engine.set_meta("_sage_thread_" + str(Time.get_ticks_msec()), thread)
	thread.start(func():
		var output := []
		var env := ["NO_COLOR=1", "TERM=dumb"]
		var code := OS.execute(full_args[0], full_args.slice(1), output, true)
		var text := "\n".join(PackedStringArray(output))
		callback.call.call_deferred(code, text)
	)
