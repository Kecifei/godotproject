# Psyphone Mystery (Godot 4.6) Dev Notes

Open with Godot 4.6.x (`4.6.1` recommended).

## Main Scene

Set main scene to:

- `res://scenes/bootstrap/Boot.tscn`

Editor path:

- `Project -> Project Settings -> Application -> Run -> Main Scene`

## Autoload Setup

Add these singletons in this order:

1. `Content` -> `res://scripts/managers/content.gd`
2. `State` -> `res://scripts/managers/state.gd`
3. `TimeSim` -> `res://scripts/managers/time_sim.gd`
4. `Notifications` -> `res://scripts/managers/notifications.gd`
5. `Audio` -> `res://scripts/managers/audio.gd`
6. `Events` -> `res://scripts/managers/events.gd`
7. `Save` -> `res://scripts/managers/save.gd`

Editor path:

- `Project -> Project Settings -> Globals -> Autoload`

Autoloads are initialized before your main scene, which is why `Boot` can call manager APIs immediately.

## Portrait + UI Scaling

Use the editor for final scaling checks if you adjust these later:

- `Project Settings -> Display -> Window -> Size`
- `Project Settings -> Display -> Window -> Stretch`

Guidance:

- Keep portrait-first base size (example: `720x1280`).
- Use `Control` nodes with anchors and containers, not fixed pixel positions.
- Prefer responsive layouts (`MarginContainer`, `VBoxContainer`, `GridContainer`).

## Android Export (Official Docs)

Official guide:

- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html

Follow the docs to configure:

- Android SDK + build tools
- Java (JDK) version required by your Godot version
- Keystore/signing for release builds
- Export template installation

Do not skip a test debug export before release signing.
