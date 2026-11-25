# Pixel Museum

Pixel Museum is a Godot 2D museum game prototype where players create pixel artwork, publish it, and place it in their museum.

## Current status

Milestone 0.5 is a local creative prototype. It includes a base side-view museum, platformer movement, artwork creation, artwork placement, artwork inspection, and local persistence. Online connection services, accounts, multiplayer presence, marketplace transactions, likes, and follows are deferred.

## Requirements

- Godot 4.7 or later with the project’s supported 2D features.
- A desktop browser or desktop environment for the current keyboard-and-mouse prototype.

Godot is not currently available on the development machine’s PATH, so runtime and browser-export validation are still pending.

## Run the game in Godot

1. Open Godot Project Manager.
2. Choose **Import**.
3. Select this repository folder.
4. Open the project.
5. Press **F6** to run the current scene or **F5** to run the configured main scene.

The configured main scene is [node_2d.tscn](node_2d.tscn).

## Run from the command line

From the repository root:

```text
godot --editor project.godot
```

To run headlessly when validating project startup:

```text
godot --headless --path . --editor --quit
```

The exact executable name may be `godot4` on some systems.

## Current controls and workflow

- **Left/Right arrows:** move through the museum.
- **Space:** jump.
- **New Artwork:** open the pixel editor.
- **Edit Artwork:** open the artwork gallery from the top panel and edit a player-created artwork without selecting a frame.
- **Full-window editor:** artwork editing takes over the museum view until publishing or cancelling.
- **Scroll-wheel zoom:** zoom the canvas from 1 to 16 screen pixels per artwork pixel; the initial fit maps 16×16 through 256×256 canvases into the editor.
- **Canvas size:** choose 16x16, 32x32, 64x64, 128x128, or 256x256.
- **Palette buttons:** choose a curated palette entry.
- **Eraser button:** select the eraser icon, then left-click pixels to erase them; selecting a palette color returns to painting mode.
- **Bottom action bar:** Clear, Publish, and Cancel are separated below the palette at the bottom of the editor.
- **Edit:** use the Edit Artwork top-panel option, then choose Edit beside a gallery entry to reopen and update player-created artwork without creating a duplicate. Frame placement pickers do not show Edit actions.
- **Click any display frame:** open the gallery picker and choose or replace its published artwork.
- **Square display frames:** every frame uses the same width and height, with artwork scaled proportionally to fit inside it.
- **No painting:** choose this gallery entry to clear an occupied frame without deleting the artwork.
- **Gallery picker sorting:** sort by alphabetical title or latest publication.
- **Gallery picker filtering:** filter by artwork canvas size; tag filtering is planned for a later milestone.
- **Save:** explicitly save local project state.

## Local persistence

The prototype saves museum state and artwork data to the Godot `user://` directory. In a web export, this is backed by the browser’s local storage filesystem. Clearing browser/site data may remove local prototype data.

The persistence boundary is implemented in [app_state.gd](scripts/app_state.gd), and the main museum flow is implemented in [museum_app.gd](scripts/museum_app.gd).

## Development notes

- Development is taking place on the `milestone-0.5` branch rather than `main`.
- The current project uses GDScript.
- Connection services are intentionally isolated for a later milestone.
- Update this README whenever the run workflow, controls, requirements, export process, or validation status changes.

## Plan

See [DEVPLAN.md](DEVPLAN.md) for the evolving product decisions, milestone scope, deferred questions, and verification criteria.
