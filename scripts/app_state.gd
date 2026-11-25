extends Node

const SAVE_PATH := "user://pixel_museum.json"
const SAVE_VERSION := 1

var museum: Dictionary = {
	"schema_version": SAVE_VERSION,
	"rooms": [{"id": "starter", "width": 32, "height": 18}],
	"display_zones": [{"id": "zone_1", "x": 220.0, "y": 250.0, "artwork_id": ""}, {"id": "zone_2", "x": 470.0, "y": 250.0, "artwork_id": ""}, {"id": "zone_3", "x": 720.0, "y": 250.0, "artwork_id": ""}]
}
var artworks: Array[Dictionary] = []
var drafts: Array[Dictionary] = []
var palette_unlocks: Array[String] = ["paper", "ink", "red", "blue", "green", "gold"]

func _ready() -> void:
	load_data()

func save_data() -> void:
	var payload := {"schema_version": SAVE_VERSION, "museum": museum, "artworks": artworks, "drafts": drafts, "palette_unlocks": palette_unlocks}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(payload))

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary and int(parsed.get("schema_version", 0)) <= SAVE_VERSION:
		museum = parsed.get("museum", museum)
		artworks.assign(parsed.get("artworks", []))
		drafts.assign(parsed.get("drafts", []))
		palette_unlocks.assign(parsed.get("palette_unlocks", palette_unlocks))

func publish_artwork(title: String, description: String, width: int, pixels: PackedByteArray) -> Dictionary:
	var artwork := {"id": "art_%s" % Time.get_unix_time_from_system(), "title": title, "creator": "You", "description": description, "width": width, "height": width, "pixels": Marshalls.raw_to_base64(pixels), "palette_version": 1, "published_at": Time.get_datetime_string_from_system()}
	artworks.append(artwork)
	save_data()
	return artwork

func latest_artwork() -> Dictionary:
	return artworks.back() if not artworks.is_empty() else {}

func artwork_by_id(artwork_id: String) -> Dictionary:
	for artwork in artworks:
		if String(artwork.get("id", "")) == artwork_id:
			return artwork
	return {}

func is_artwork_displayed(artwork_id: String) -> bool:
	for zone in museum["display_zones"]:
		if String(zone.get("artwork_id", "")) == artwork_id:
			return true
	return false

func place_artwork_in_zone(zone_id: String, artwork_id: String) -> bool:
	var artwork := artwork_by_id(artwork_id)
	if artwork.is_empty():
		return false
	for zone in museum["display_zones"]:
		if String(zone.get("artwork_id", "")) == artwork_id:
			zone["artwork_id"] = ""
	for zone in museum["display_zones"]:
		if String(zone.get("id", "")) == zone_id:
			zone["artwork_id"] = artwork_id
			save_data()
			return true
	return false

func artwork_for_zone(zone: Dictionary) -> Dictionary:
	var artwork_id := String(zone.get("artwork_id", ""))
	for artwork in artworks:
		if artwork.get("id", "") == artwork_id:
			return artwork
	return {}
