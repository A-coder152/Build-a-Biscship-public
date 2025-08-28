extends Control

func _on_inventory_pressed() -> void:
	get_tree().current_scene.change_bar("inventory")

func _on_upgrades_pressed() -> void:
	get_tree().current_scene.change_bar("upgrades")
