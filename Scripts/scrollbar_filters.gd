extends Control

func _on_inventory_pressed() -> void:
	get_tree().current_scene.change_bar("inventory")

func _on_upgrades_pressed() -> void:
	get_tree().current_scene.change_bar("upgrades")

func _on_structure_pressed() -> void:
	get_tree().current_scene.change_filter(Part.TYPE.STRUCTURE)

func _on_engine_pressed() -> void:
	get_tree().current_scene.change_filter(Part.TYPE.ENGINE)

func _on_fuel_pressed() -> void:
	get_tree().current_scene.change_filter(Part.TYPE.FUEL)

func _on_filling_pressed() -> void:
	get_tree().current_scene.change_filter(Part.TYPE.FILLING)

func _on_coating_pressed() -> void:
	get_tree().current_scene.change_filter(Part.TYPE.COATING)
