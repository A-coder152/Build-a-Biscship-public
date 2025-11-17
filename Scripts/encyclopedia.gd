extends Control

@onready var item_title = $VBoxContainer/Item
@onready var image = $VBoxContainer/HBoxContainer/Image
@onready var cost_label = $VBoxContainer/HBoxContainer/VBoxContainer2/Cost
@onready var value_label = $VBoxContainer/HBoxContainer/VBoxContainer2/Value
@onready var owned_label = $VBoxContainer/HBoxContainer/VBoxContainer2/Owned
@onready var success_label = $VBoxContainer/HBoxContainer/VBoxContainer3/Success
@onready var weight_label = $VBoxContainer/HBoxContainer/VBoxContainer3/Weight
@onready var special_label = $VBoxContainer/HBoxContainer/VBoxContainer3/Spceial
@onready var infobox = $VBoxContainer/VBoxContainer/info
@onready var info_title_label = $VBoxContainer/VBoxContainer/info/title
@onready var info_label = $VBoxContainer/VBoxContainer/info/text
@onready var tilesbox = $VBoxContainer/VBoxContainer/tiles
@onready var tiles_title_label = $VBoxContainer/VBoxContainer/tiles/title
@onready var tiles_label = $VBoxContainer/VBoxContainer/tiles/text
@onready var coolbox = $VBoxContainer/VBoxContainer/cool
@onready var cool_title_label = $VBoxContainer/VBoxContainer/cool/title
@onready var cool_label = $VBoxContainer/VBoxContainer/cool/text
@onready var cool2box = $VBoxContainer/VBoxContainer/cool2
@onready var cool2_title_label = $VBoxContainer/VBoxContainer/cool2/title
@onready var cool2_label = $VBoxContainer/VBoxContainer/cool2/text

var infos = {
	"ENGINE: ": "Needed for the rocket to fly! Do not place items below it or they will be incinerated.",
	"FUEL: ": "The rocket juice required to reach far distances!",
	"FILLING: ": "A tasty filling to make your biscships more valuable!",
	"COATING: ": "Protects parts around it, giving them a lower failure chance!",
	"STRUCTURE: ": "The main building blocks of the rocket!",
	"Aerodynamic Structure: ": "Special structure that can reduce the rocket's drag!"
}

func change_content(item: Part):
	item_title.text = item.part_name
	image.texture = item.images[0]
	cost_label.text = "Cost: " + str(item.cost)
	value_label.text = "Value: " + str(item.value)
	owned_label.text = "Owned: " + str(item.owned)
	success_label.text = "Success: " + str(round(item.success * 10000) / 100.) + "%"
	weight_label.text = "Weight: " + str(item.weight)
	special_label.text = item.special_name + ": " + str(item.special)
	info_title_label.text = (Part.TYPE.keys()[item.type] + ": ") if not item.special_name == "drag" else "Aerodynamic Structure: "
	info_label.text = infos[info_title_label.text]
	tilesbox.visible = item.tile_type != item.TILE.NONE
	if tilesbox.visible:
		match item.tile_type:
			Part.TILE.RULE:
				tiles_title_label.text = "Orange Tile: "
				tiles_label.text = "Only allows structures or similar parts."
				if item.type == item.TYPE.FILLING: tiles_label.text += "\nMust be covered for filling to have value."
			Part.TILE.EFFECT:
				tiles_title_label.text = "Yellow Tile: "
				tiles_label.text = "Leave empty to allow special effects."
			Part.TILE.BENEFIT:
				tiles_title_label.text = "Blue Tile: "
				tiles_label.text = "Parts on blue tiles are affected by coating,\nincreasing success chances by x%."
	coolbox.visible = item.blocks != Vector2(2.0, 2.0)
	if coolbox.visible:
		match item.blocks:
			Vector2(1.0, 1.0):
				cool_title_label.text = "Mini: "
				cool_label.text = "A tiny, versatile 1x1 part!"
			Vector2(4.0, 2.0):
				cool_title_label.text = "Dual: "
				cool_label.text = "Double the power! Double the size!"
			Vector2(3.0, 3.0):
				cool_title_label.text = "Large: "
				cool_label.text = "Takes up a 3x3 space to allow for more!"
			Vector2(1.0, 2.0):
				cool_title_label.text = "Wing: "
				cool_label.text = "Takes up a 1x2 space to effectively reduce drag!"
	cool2_label.text = ""
	cool2_title_label.text = ""
	cool2box.visible = false
	for thingy in ["Choc", "Multi", "Pink", "Window", "Strawberry"]:
		if item.part_name.contains(thingy):
			print(thingy, item.part_name)
			cool2box.visible = true
			cool2_title_label.text += thingy
			if thingy != "Multi": cool2_label.text += "Higher risk, higher reward! "
			else: cool2_label.text += "Higher risk for more power!"
	if cool2_title_label.text != "": cool2_title_label.text += ": "
