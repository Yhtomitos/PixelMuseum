extends Node2D

var player_position := Vector2(100, 380)
var velocity := Vector2.ZERO
var construction_mode := false
var editor: PanelContainer
var gallery_picker: GalleryPicker
var info_label: Label
var selected_artwork: Dictionary = {}
var gallery_zone_id := ""
var artwork_textures: Dictionary = {}
var palette_colors: Array[Color] = [Color("#fff4d6"), Color("#201a2b"), Color("#d94f70"), Color("#4f83d9"), Color("#65b86f"), Color("#e6b84f")]

func _ready() -> void:
	_build_hud()
	queue_redraw()

func _process(delta: float) -> void:
	if not construction_mode and editor == null and gallery_picker == null:
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
	if editor != null or gallery_picker != null or not event is InputEventMouseButton or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
		return
	for zone in AppState.museum.get("display_zones", []):
		var position := Vector2(zone["x"], zone["y"])
		if Rect2(position - Vector2(70, 70), Vector2(140, 110)).has_point(event.position):
			_open_gallery_picker(String(zone.get("id", "")))
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
			var texture: Texture2D = _artwork_texture(artwork)
			if texture:
				draw_texture_rect(texture, Rect2(position - Vector2(58, 58), Vector2(116, 72)), false)
	draw_circle(player_position, 16.0, Color("#65b86f"))
	draw_rect(Rect2(player_position + Vector2(-12, 14), Vector2(24, 8)), Color("#201a2b"))

func _artwork_texture(artwork: Dictionary) -> Texture2D:
	var artwork_id := String(artwork.get("id", ""))
	if artwork_textures.has(artwork_id):
		return artwork_textures[artwork_id]
	var width := int(artwork.get("width", 0))
	var height := int(artwork.get("height", width))
	var indexed_pixels: PackedByteArray = Marshalls.base64_to_raw(String(artwork.get("pixels", "")))
	if width <= 0 or height <= 0 or indexed_pixels.size() < width * height:
		return null
	var rgba := PackedByteArray()
	rgba.resize(width * height * 4)
	for index in width * height:
		var color_index := int(indexed_pixels[index])
		var color := palette_colors[color_index] if color_index < palette_colors.size() else palette_colors[0]
		rgba[index * 4] = int(color.r * 255.0)
		rgba[index * 4 + 1] = int(color.g * 255.0)
		rgba[index * 4 + 2] = int(color.b * 255.0)
		rgba[index * 4 + 3] = 255
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.set_data(width, height, false, Image.FORMAT_RGBA8, rgba)
	var texture: Texture2D = ImageTexture.create_from_image(image)
	artwork_textures[artwork_id] = texture
	return texture

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
	if editor != null or gallery_picker != null:
		return
	editor = preload("res://scripts/pixel_editor.gd").new()
	editor.position = Vector2(220, 46)
	editor.published.connect(_on_artwork_published)
	add_child(editor)

func _on_artwork_published(artwork: Dictionary) -> void:
	selected_artwork = artwork
	_remove_editor()
	info_label.text = "Published '%s'. Click any frame to choose or replace its painting." % artwork["title"]

func _remove_editor() -> void:
	if editor:
		editor.queue_free()
		editor = null

func _open_gallery_picker(zone_id: String) -> void:
	if gallery_picker != null or AppState.artworks.is_empty():
		info_label.text = "Publish a painting before selecting one for this frame." if AppState.artworks.is_empty() else "Choose a painting for this frame."
		return
	gallery_zone_id = zone_id
	gallery_picker = preload("res://scripts/gallery_picker.gd").new()
	gallery_picker.position = Vector2(220, 56)
	gallery_picker.setup(zone_id)
	gallery_picker.artwork_selected.connect(_on_gallery_artwork_selected)
	gallery_picker.painting_removed.connect(_remove_gallery_painting)
	gallery_picker.closed.connect(_close_gallery_picker)
	add_child(gallery_picker)

func _on_gallery_artwork_selected(artwork_id: String) -> void:
	if AppState.place_artwork_in_zone(gallery_zone_id, artwork_id):
		info_label.text = "Painting placed. Click any frame to choose or replace its painting."
	_close_gallery_picker()
	queue_redraw()

func _remove_gallery_painting() -> void:
	if AppState.clear_artwork_from_zone(gallery_zone_id):
		info_label.text = "Painting removed from the frame and returned to the gallery."
	_close_gallery_picker()
	queue_redraw()

func _close_gallery_picker() -> void:
	if gallery_picker:
		gallery_picker.queue_free()
		gallery_picker = null

func _toggle_construction() -> void:
	construction_mode = not construction_mode
	info_label.text = "Construction mode: preview and placement tools coming next." if construction_mode else "Visitor mode active."
