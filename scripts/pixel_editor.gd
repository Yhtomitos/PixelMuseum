extends PanelContainer

signal published(artwork: Dictionary)

var canvas_size := 16
var pixels := PackedByteArray()
var selected_index := 1
var grid: Control
var title_input: LineEdit
var description_input: TextEdit
var size_select: OptionButton
var status_label: Label
var colors := [Color("#fff4d6"), Color("#201a2b"), Color("#d94f70"), Color("#4f83d9"), Color("#65b86f"), Color("#e6b84f")]

func _ready() -> void:
	custom_minimum_size = Vector2(520, 440)
	pixels.resize(canvas_size * canvas_size)
	_build_ui()

func _build_ui() -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)
	var column := VBoxContainer.new()
	margin.add_child(column)
	var heading := Label.new()
	heading.text = "Create artwork"
	heading.add_theme_font_size_override("font_size", 22)
	column.add_child(heading)
	var row := HBoxContainer.new()
	column.add_child(row)
	title_input = LineEdit.new()
	title_input.placeholder_text = "Artwork title"
	title_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title_input)
	size_select = OptionButton.new()
	for size in [16, 32, 64, 128, 256]:
		size_select.add_item("%sx%s" % [size, size], size)
	size_select.item_selected.connect(_on_size_selected)
	row.add_child(size_select)
	description_input = TextEdit.new()
	description_input.placeholder_text = "Description"
	description_input.custom_minimum_size.y = 48
	column.add_child(description_input)
	grid = _PixelGrid.new()
	grid.custom_minimum_size = Vector2(300, 300)
	grid.pixel_changed.connect(_on_pixel_changed)
	column.add_child(grid)
	var palette := HBoxContainer.new()
	column.add_child(palette)
	for index in colors.size():
		var swatch := Button.new()
		swatch.text = "  "
		swatch.tooltip_text = "Palette entry %s" % index
		swatch.modulate = colors[index]
		swatch.pressed.connect(_select_color.bind(index))
		palette.add_child(swatch)
	var actions := HBoxContainer.new()
	column.add_child(actions)
	var clear := Button.new()
	clear.text = "Clear"
	clear.pressed.connect(_clear_canvas)
	actions.add_child(clear)
	var publish_button := Button.new()
	publish_button.text = "Publish"
	publish_button.pressed.connect(_publish)
	actions.add_child(publish_button)
	status_label = Label.new()
	column.add_child(status_label)
	_refresh_grid()

func _on_size_selected(index: int) -> void:
	canvas_size = size_select.get_item_id(index)
	pixels.resize(canvas_size * canvas_size)
	_refresh_grid()

func _select_color(index: int) -> void:
	selected_index = index

func _on_pixel_changed(index: int) -> void:
	if index >= 0 and index < pixels.size():
		pixels[index] = selected_index
		grid.queue_redraw()

func _clear_canvas() -> void:
	pixels.fill(0)
	grid.queue_redraw()

func _refresh_grid() -> void:
	grid.configure(canvas_size, pixels, colors)

func _publish() -> void:
	var title := title_input.text.strip_edges()
	if title.is_empty():
		status_label.text = "Add a title before publishing."
		return
	var artwork := AppState.publish_artwork(title, description_input.text.strip_edges(), canvas_size, pixels)
	status_label.text = "Published: %s" % title
	published.emit(artwork)

class _PixelGrid extends Control:
	signal pixel_changed(index: int)
	var canvas_cells := 16
	var pixels := PackedByteArray()
	var colors: Array[Color] = []

	func configure(next_size: int, next_pixels: PackedByteArray, next_colors: Array[Color]) -> void:
		canvas_cells = next_size
		pixels = next_pixels
		colors = next_colors
		queue_redraw()

	func _draw() -> void:
		var cell: float = minf(self.size.x, self.size.y) / float(canvas_cells)
		for y in canvas_cells:
			for x in canvas_cells:
				var index := y * canvas_cells + x
				var color := colors[pixels[index]] if index < pixels.size() and pixels[index] < colors.size() else colors[0]
				draw_rect(Rect2(x * cell, y * cell, cell, cell), color)
				if canvas_cells <= 64:
					draw_rect(Rect2(x * cell, y * cell, cell, cell), Color("#5b536b"), false, 1.0)

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var cell: float = minf(self.size.x, self.size.y) / float(canvas_cells)
			var point: Vector2 = event.position / cell
			pixel_changed.emit(int(point.y) * canvas_cells + int(point.x))
