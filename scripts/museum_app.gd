extends Node2D

var player_position := Vector2(100, 380)
var velocity := Vector2.ZERO
var construction_mode := false
var editor: PanelContainer
var info_label: Label
var selected_artwork: Dictionary = {}

func _ready() -> void:
	_build_hud()
	queue_redraw()

func _process(delta: float) -> void:
	if not construction_mode and editor == null:
		velocity.x = Input.get_axis("ui_left", "ui_right") * 220.0
		if Input.is_action_just_pressed("ui_accept") and player_position.y >= 379.0:
			velocity.y = -390.0
		velocity.y += 980.0 * delta
		player_position += velocity * delta
		player_position.x = clamp(player_position.x, 32.0, 930.0)
		player_position.y = min(player_position.y, 380.0)
		if player_position.y >= 380.0:
			velocity.y = 0.0
		queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if editor != null or not event is InputEventMouseButton or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	for zone in AppState.museum.get("display_zones", []):
		var position := Vector2(zone["x"], zone["y"])
		if Rect2(position - Vector2(70, 70), Vector2(140, 110)).has_point(event.position):
			var artwork := AppState.artwork_for_zone(zone)
			if not artwork.is_empty():
				info_label.text = "%s by %s | %sx%s | %s" % [artwork["title"], artwork["creator"], artwork["width"], artwork["height"], artwork["description"]]
			else:
				info_label.text = "This display zone is ready for artwork."
			return

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("#17152b"))
	draw_rect(Rect2(24, 72, 912, 376), Color("#302b4f"))
	draw_rect(Rect2(24, 448, 912, 24), Color("#8f6b58"))
	draw_rect(Rect2(24, 150, 912, 10), Color("#574f78"))
	draw_rect(Rect2(24, 300, 912, 10), Color("#574f78"))
	for zone in AppState.museum.get("display_zones", []):
		var position := Vector2(zone["x"], zone["y"])
		draw_rect(Rect2(position - Vector2(70, 70), Vector2(140, 110)), Color("#181526"))
		draw_rect(Rect2(position - Vector2(70, 70), Vector2(140, 110)), Color("#d1a86f"), false, 4.0)
		var artwork := AppState.artwork_for_zone(zone)
		if not artwork.is_empty():
			draw_string(ThemeDB.fallback_font, position - Vector2(55, 10), String(artwork["title"]).left(14), HORIZONTAL_ALIGNMENT_LEFT, 110, 14, Color("#fff4d6"))
			draw_string(ThemeDB.fallback_font, position - Vector2(55, -18), "Inspect", HORIZONTAL_ALIGNMENT_LEFT, 110, 12, Color("#b5a7d6"))
	draw_circle(player_position, 16.0, Color("#65b86f"))
	draw_rect(Rect2(player_position + Vector2(-12, 14), Vector2(24, 8)), Color("#201a2b"))

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(16, 14)
	panel.size = Vector2(928, 46)
	layer.add_child(panel)
	var row := HBoxContainer.new()
	panel.add_child(row)
	var title := Label.new()
	title.text = "Pixel Museum 0.5"
	title.add_theme_font_size_override("font_size", 20)
	row.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var create := Button.new()
	create.text = "New Artwork"
	create.pressed.connect(_open_editor)
	row.add_child(create)
	var place := Button.new()
	place.text = "Place Latest"
	place.pressed.connect(_place_latest)
	row.add_child(place)
	var build := Button.new()
	build.text = "Construction"
	build.pressed.connect(_toggle_construction)
	row.add_child(build)
	var save := Button.new()
	save.text = "Save"
	save.pressed.connect(AppState.save_data)
	row.add_child(save)
	info_label = Label.new()
	info_label.position = Vector2(34, 490)
	info_label.text = "Arrow keys move | Space jumps | Create artwork, publish it, then place it in a display zone"
	layer.add_child(info_label)

func _open_editor() -> void:
	if editor != null:
		return
	editor = preload("res://scripts/pixel_editor.gd").new()
	editor.position = Vector2(220, 46)
	editor.published.connect(_on_artwork_published)
	add_child(editor)

func _on_artwork_published(artwork: Dictionary) -> void:
	selected_artwork = artwork
	_remove_editor()
	info_label.text = "Published '%s'. Press Place Latest to add it to an open display zone." % artwork["title"]

func _remove_editor() -> void:
	if editor:
		editor.queue_free()
		editor = null

func _place_latest() -> void:
	if AppState.place_latest_artwork():
		info_label.text = "Artwork placed in the next open display zone. Click Inspect on a display to view it."
	else:
		info_label.text = "Publish an artwork first, or make room by removing a display later."
	queue_redraw()

func _toggle_construction() -> void:
	construction_mode = not construction_mode
	info_label.text = "Construction mode: preview and placement tools coming next." if construction_mode else "Visitor mode active."
