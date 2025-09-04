extends Control

var item
var main_scene

@onready var img = $img

@export var click: AudioStream

func setup(dict):
	main_scene = get_tree().current_scene
	item = dict
	$Name.text = item.part_name
	img.texture = item.images[item.upgrade_counter]
	img.scale = Vector2(min(1, img.texture.get_width() / float(img.texture.get_height())), min(1, img.texture.get_height() / float(img.texture.get_width())))
	update()

func update():
	$SuccessText.text = str(round(item.success * 10000) / 100.) + "% -> " + str(round((item.success + (1 - item.success) * 0.1) * 10000) / 100.) + "%"
	$ValueText.text = str(round(item.value * 100) / 100.) + " -> " + str(round((item.value * 1.1) * 100) / 100.)
	$WeightText.text = str(round(item.weight * 100) / 100.) + " -> " + str(round((item.weight * 0.9) * 100) / 100.)
	$Value.text = str(item.value_upgrade_cost) + "BP"
	$Success.text = str(item.success_upgrade_cost) + "BP"
	$Weight.text = str(item.weight_upgrade_cost) + "BP"
	if item.special_name:
		$Special.text = str(item.special_upgrade_cost) + "BP"
		if item.special_name in Part.SPECIAL_UPPERS:
			$SpecialText.text = str(round(item.special * 100) / 100.) + " -> " + str(round((item.special * 1.1) * 100) / 100.)
			$BuySpecial.text = "+ " + item.special_name
		elif item.special_name in Part.SPECIAL_DOWNERS:
			$SpecialText.text = str(round(item.special * 100) / 100.) + " -> " + str(round((item.special * 0.9) * 100) / 100.)
			$BuySpecial.text = "- " + item.special_name
	else:
		$Special.visible = false
		$SpecialText.visible = false
		$BuySpecial.visible = false

func _on_buy_pressed() -> void:
	main_scene.upgrade_value(item)
	Sound.play_sfx(click, 0.1, 1, -3)

func _on_add_pressed() -> void:
	main_scene.upgrade_success(item)
	Sound.play_sfx(click, 0.1, 1, -3)

func _on_buy_special_pressed() -> void:
	main_scene.upgrade_special(item)
	Sound.play_sfx(click, 0.1, 1, -3)

func _on_buy_weight_pressed() -> void:
	main_scene.upgrade_weight(item)
	Sound.play_sfx(click, 0.1, 1, -3)
