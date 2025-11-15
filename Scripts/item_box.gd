extends Control

var item
var main_scene

@onready var image = $img

@export var click: AudioStream
@export var add_sound: AudioStream

func setup(dict):
	main_scene = get_tree().current_scene
	item = dict
	if len(item.part_name) > 10: $Name.set("theme_override_font_sizes/font_size", 160/len(item.part_name))
	$Name.text = item.part_name
	$Type.text = item.TYPE.keys()[item.type]
	var img = item.images[item.upgrade_counter]
	var scail = Vector2(min(1, img.get_width() / float(img.get_height())), min(1, img.get_height() / float(img.get_width())))
	image.texture = img
	image.scale = Vector2(min(1, img.get_width() / float(img.get_height())), min(1, img.get_height() / float(img.get_width())))
	image.position += Vector2(42.5 * float(1. - scail.x), 42.5 * float(1. - scail.y))
	update()

func update():
	$Owned.text = "Owned: " + str(item.owned)
	$Success.text = "Success: " + str(round(item.success * 10000) / 100.) + "%"
	$Value.text = "Value: " + str(item.value)
	$Cost.text = "Cost: " + str(item.cost)

func _on_buy_pressed() -> void:
	main_scene.buy_item(item)
	Sound.play_sfx(click, 0.1, 1, -3)
func _on_add_pressed() -> void:
	main_scene.add_item_to_rocket(item)
	Sound.play_sfx(add_sound, 0, 1, -1)
