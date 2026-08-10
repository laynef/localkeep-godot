<p align="center">
  <img src="https://raw.githubusercontent.com/laynef/localkeep-godot/main/icon.png" width="96" alt="Local Keep AI" />
</p>

# Local Keep AI for Godot 4

Local-first AI coding assistant for Godot 4 game development — explain GDScript,
generate state machines, write GUT tests, and run agentic tasks against 200+ free
models.

## Install

Not yet in the Godot Asset Library. Install manually:

```bash
git clone https://github.com/laynef/localkeep-godot
cp -r sage-godot/addons/local_keep_ai /path/to/your/project/addons/
```

Then enable it: **Project → Project Settings → Plugins → Local Keep AI → Enable**.

## Requires

Godot **4.x** and the sage CLI:

```bash
pip install local-keep-ai-cli
sage login
```

## Features

- **Local Keep AI dock**, bottom-right — chat, run tasks, view output
- **Project → Tools → Local Keep AI: Explain Script** — explains the script open in the editor
- **Project → Tools → Local Keep AI: Generate GUT Tests** — GUT tests for the current script
- **Project → Tools → Local Keep AI: List Models** — shows every available model

## Layout

```
addons/local_keep_ai/plugin.cfg      addon manifest (name, version, script entry point)
addons/local_keep_ai/plugin.gd       EditorPlugin — docks and Tools menu items
addons/local_keep_ai/lk_dock.tscn  dock scene
addons/local_keep_ai/lk_dock.gd    dock logic
addons/local_keep_ai/lk_client.gd  sage binary discovery + threaded OS.execute
```

The addon must stay at `addons/local_keep_ai/` — the Asset Library extracts archives
relative to the project root, and `plugin.gd` preloads
`res://addons/local_keep_ai/lk_dock.tscn` by absolute resource path.

## Notes

`lk_client.gd` runs `sage` on a `Thread` and marshals the result back with
`call_deferred`, so the editor stays responsive during long agentic tasks.

Publishing to the Asset Library requires an account there — see
[`../PUBLISH.md`](../PUBLISH.md) § 3.7.

## License

MIT — [localkeep.ai](https://localkeep.ai)
