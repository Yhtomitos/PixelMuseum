extends PanelContainer
class_name GalleryPicker

signal artwork_selected(artwork_id: String)
signal painting_removed
signal closed

var sort_select: OptionButton
var size_select: OptionButton
var list: VBoxContainer
var zone_id := ""
var palette_colors: Array[Color] = [Color("#fff4d6"), Color("#201a2b"), Color("#d94f70"), Color("#4f83d9"), Color("#65b86f"), Color("#e6b84f")]

func setup(target_zone_id: String) -> void:
	zone_id = target_zone_id
	_build_ui()
	_refresh_gallery()

func _build_ui() -> void:
	custom_minimum_size = Vector2(520, 420)
	var margin := MarginContainer.new()
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 16)
	add_child(margin)
	var column := VBoxContainer.new()
	margin.add_child(column)
	var heading := Label.new()
	heading.text = "Choose a painting for this frame"
	heading.add_theme_font_size_override("font_size", 20)
	column.add_child(heading)
	var controls := HBoxContainer.new()
	column.add_child(controls)
	sort_select = OptionButton.new()
	sort_select.add_item("Title A-Z", 0)
	sort_select.add_item("Latest", 1)
	sort_select.item_selected.connect(_refresh_gallery)
	controls.add_child(sort_select)
	size_select = OptionButton.new()
	size_select.add_item("All sizes", 0)
	for size in [16, 32, 64, 128, 256]:
		size_select.add_item("%sx%s" % [size, size], size)
	size_select.item_selected.connect(_refresh_gallery)
	controls.add_child(size_select)
	var tags := Label.new()
	tags.text = "Tags: coming later"
	tags.modulate = Color("#8d86a8")
	controls.add_child(tags)
	list = VBoxContainer.new()
	list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(list)
	var cancel := Button.new()
	cancel.text = "Cancel"
	cancel.pressed.connect(closed.emit)
	column.add_child(cancel)

func _refresh_gallery(_index: int = 0) -> void:
	if list == null:
		return
	for child in list.get_children():
		child.queue_free()
	if _zone_has_artwork():
		var no_painting := Button.new()
		no_painting.text = "No painting  |  Leave this frame empty"
		no_painting.alignment = HORIZONTAL_ALIGNMENT_LEFT
		no_painting.pressed.connect(painting_removed.emit)
		list.add_child(no_painting)
	var entries: Array[Dictionary] = []
	var requested_size: int = size_select.get_selected_id() if size_select else 0
	for artwork in AppState.artworks:
		if AppState.is_artwork_displayed(String(artwork.get("id", ""))):
			continue
		if requested_size != 0 and int(artwork.get("width", 0)) != requested_size:
			continue
		entries.append(artwork)
	if sort_select and sort_select.get_selected_id() == 0:
		entries.sort_custom(_sort_title)
	else:
		entries.sort_custom(_sort_latest)
	if entries.is_empty():
		var empty := Label.new()
		empty.text = "No published paintings match this filter."
		list.add_child(empty)
		return
	for artwork in entries:
		var row := HBoxContainer.new()
		var preview := TextureRect.new()
		preview.custom_minimum_size = Vector2(96, 64)
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		preview.texture = _artwork_texture(artwork)
		row.add_child(preview)
		var button := Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.text = "%s  |  %sx%s  |  %s" % [artwork.get("title", "Untitled"), artwork.get("width", 0), artwork.get("height", 0), artwork.get("published_at", "")]
		button.pressed.connect(_select_artwork.bind(String(artwork.get("id", ""))))
		row.add_child(button)
		list.add_child(row)

func _artwork_texture(artwork: Dictionary) -> Texture2D:
	var width := int(artwork.get("width", 0))
	var height := int(artwork.get("height", width))
	var indexed_pixels: PackedByteArray = Marshalls.base64_to_raw(String(artwork.get("pixels", "")))
	if width <= 0 or height <= 0 or indexed_pixels.size() < width * height:
		return null
	var rgba := PackedByteArray()
	rgba.resize(width * height * 4)
	for index in width * height:
		var color_index := int(indexed_pixels[index])
		var color: Color = palette_colors[color_index] if color_index < palette_colors.size() else palette_colors[0]
		rgba[index * 4] = int(color.r * 255.0)
		rgba[index * 4 + 1] = int(color.g * 255.0)
		rgba[index * 4 + 2] = int(color.b * 255.0)
		rgba[index * 4 + 3] = 255
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.set_data(width, height, false, Image.FORMAT_RGBA8, rgba)
	return ImageTexture.create_from_image(image)

func _sort_title(left: Dictionary, right: Dictionary) -> bool:
	return String(left.get("title", "")).to_lower() < String(right.get("title", "")).to_lower()

func _sort_latest(left: Dictionary, right: Dictionary) -> bool:
	return String(left.get("published_at", "")) > String(right.get("published_at", ""))

func _select_artwork(artwork_id: String) -> void:
	artwork_selected.emit(artwork_id)

func _zone_has_artwork() -> bool:
	for zone in AppState.museum.get("display_zones", []):
		if String(zone.get("id", "")) == zone_id:
			return not String(zone.get("artwork_id", "")).is_empty()
	return false
