extends Control

var item
var main_scene

@export var click: AudioStream

func setup(dict):
	main_scene = get_tree().current_scene
	item = dict
	$Name.text = item.part_name
	$img.texture = item.image
	update()

func update():
	$Owned.text = "Owned: " + str(item.owned)
	$Success.text = "Success: " + str(round(item.success * 10000) / 100.) + "%"
	$Value.text = "Value: " + str(item.value)
	$Cost.text = "Cost: " + str(item.cost)

func _on_buy_pressed() -> void:
	main_scene.buy_item(item)
	Sound.play_sfx(click)
func _on_add_pressed() -> void:
	main_scene.add_item_to_rocket(item)
	Sound.play_sfx(click)
