extends Control

var item: Part
var main_scene

func setup(dict):
	main_scene = get_tree().current_scene
	item = dict
	$Name.text = item.part_name
	$img.texture = item.image
	update()

func update():
	$Success.text = str(round(item.success * 10000) / 100.) + "% -> " + str(round((item.success + (1 - item.success) * 0.1) * 10000) / 100.) + "% ($" + str(item.success_upgrade_cost) +")"
	$Value.text = str(round(item.value * 100) / 100.) + " -> " + str(round((item.value * 1.1) * 100) / 100.) + " ($" + str(item.value_upgrade_cost) +")"

func _on_buy_pressed() -> void:
	main_scene.upgrade_value(item)

func _on_add_pressed() -> void:
	main_scene.upgrade_success(item)
