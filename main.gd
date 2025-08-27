extends Node2D

# Game Variables
var cash = 1000
var biscuit_points = 0

# Ingredient Stats
var dough_value = 10
var dough_success_chance = 0.5

var filling_value = 20
var filling_success_chance = 0.6

var items = [
	{
		"name": "Dough",
		"image": preload("res://icon.svg"),
		"owned": 0,
		"success": 0.5,
		"value": 10,
		"cost": 8
	},
	{
		"name": "Filling",
		"image": preload("res://icon.svg"),
		"owned": 0,
		"success": 0.6,
		"value": 20,
		"cost": 20
	},
	{
		"name": "risky one",
		"image": preload("res://icon.svg"),
		"owned": 0,
		"success": 0.1,
		"value": 101,
		"cost": 20
	},
	{
		"name": "not risky one",
		"image": preload("res://icon.svg"),
		"owned": 0,
		"success": 0.97,
		"value": 201,
		"cost": 400
	}
]

var items_scene = preload("res://item_box.tscn")

# Rocket Variables
var rocket_parts = []
var rocket_value = 0
var rocket_cost = 0
var rocket_success_chance = 0.0
var rocket_total_value = 0
var rocket_total_probability = 0

#Placement variables
@onready var grid: GridContainer = $grid
const OBJ = preload("res://test.tscn")
var gridSize: Vector2
var targetcell
var obj
var objectCells
var isValid = false

# UI Node References
@onready var cash_label = $UI/VBoxContainer/CashLabel
@onready var points_label = $UI/VBoxContainer/PointsLabel
@onready var rocket_value_label = $UI/VBoxContainer/ValueLabel
@onready var fail_chance_label = $UI/VBoxContainer/FailureChanceLabel
@onready var dough_stats_label = $UI/VBoxContainer/HBoxContainer/DoughContainer/DoughStatsLabel
@onready var filling_stats_label = $UI/VBoxContainer/HBoxContainer/FillingContainer/FillingStatsLabel
@onready var launch_button = $UI/LaunchButton
@onready var message_log = $UI/MessageLog
@onready var items_container = $UI/VBoxContainer/HBoxContainer/ScrollContainer/ItemsContainer

func _ready():
	# Initial UI update and connect signals
	reset_items_container()
	update_ui()
	$UI/VBoxContainer/HBoxContainer/DoughContainer/AddDoughButton.connect("pressed", _on_add_dough_button_pressed)
	$UI/VBoxContainer/HBoxContainer/FillingContainer/AddFillingButton.connect("pressed", _on_add_filling_button_pressed)
	$UI/VBoxContainer/UpgradeContainer/UpgradeDoughButton.connect("pressed", _on_upgrade_dough_button_pressed)
	$UI/VBoxContainer/UpgradeContainer/UpgradeFillingButton.connect("pressed", _on_upgrade_filling_button_pressed)
	$UI/VBoxContainer/UpgradeContainer/SellBiscuits.connect("pressed", _on_sell_biscuits_button_pressed)
	launch_button.connect("pressed", _on_launch_button_pressed)
	
	gridSize = Vector2(grid.cellWidth, grid.cellHeight)

func update_ui():
	# Updates all the UI labels with the current game state
	cash_label.text = "Cash: $%s" % cash
	points_label.text = "Biscuit Points: %s" % biscuit_points
	rocket_value_label.text = "Rocket Value: %s" % rocket_value
	fail_chance_label.text = "Rocket Success Chance: %s%%" % (round(rocket_success_chance * 100))
	dough_stats_label.text = "Value: %s\nSuccess Chance: %s%%" % [dough_value, dough_success_chance * 100]
	filling_stats_label.text = "Value: %s\nSuccess Chance: %s%%" % [filling_value, filling_success_chance * 100]
	update_items_container()

func _on_add_dough_button_pressed():
	# Add a 'Dough' part to the rocket
	add_part({"value": dough_value, "fail_chance": dough_success_chance})
	message_log.text = "Dough added to rocket."

func _on_add_filling_button_pressed():
	# Add a 'Filling' part to the rocket
	add_part({"value": filling_value, "fail_chance": filling_success_chance})
	message_log.text = "Filling added to rocket."

func add_part(part):
	# General function to add a part, update cost and failure chance
	rocket_parts.append(part)
	if rocket_success_chance:
		rocket_success_chance *= part.success
	else:
		rocket_success_chance = part.success
	rocket_total_value += part.value
	rocket_total_probability += part.success
	rocket_cost += part.cost
	rocket_value = rocket_total_value * rocket_total_probability / len(rocket_parts) / rocket_success_chance
	if len(rocket_parts) > 1: rocket_value /= sqrt(len(rocket_parts) - 1)
	update_ui()

func _on_launch_button_pressed():
	if rocket_parts.size() == 0:
		message_log.text = "You need to add parts to your rocket first!"
		return
		
		# Generate a random number between 0 and 1. If it's greater than the failure chance, the launch succeeds.
	if randf() < rocket_success_chance:
		# Launch Success!
		var total_points = rocket_value
		
		biscuit_points += total_points
		message_log.text = "Launch SUCCESS! Your rocket reached space and you earned %s Biscuit Points!" % total_points
	else:
		# Launch Failure
		message_log.text = "Launch FAILED! The rocket exploded and you lost $%s." % rocket_cost
	
	# Reset rocket for the next launch
	rocket_parts.clear()
	rocket_value = 0
	rocket_cost = 0
	rocket_success_chance = 0.0
	rocket_total_value = 0
	rocket_total_probability = 0
	
	update_ui()

func _on_upgrade_dough_button_pressed():
	# Upgrade 'Dough' part for a cost in biscuit points
	var upgrade_cost = 50
	if biscuit_points >= upgrade_cost:
		biscuit_points -= upgrade_cost
		dough_value = int(dough_value * 1.2) # Increase value by 20%
		dough_success_chance = min(0.9, dough_success_chance + 0.05) # Decrease failure chance, with a minimum of 10%
		message_log.text = "Dough upgraded! Value: %s, Success Chance: %s%%" % [dough_value, dough_success_chance * 100]
	else:
		message_log.text = "Not enough Biscuit Points to upgrade Dough! You need %s." % upgrade_cost
	update_ui()

func _on_upgrade_filling_button_pressed():
	# Upgrade 'Filling' part for a cost in biscuit points
	var upgrade_cost = 75
	if biscuit_points >= upgrade_cost:
		biscuit_points -= upgrade_cost
		filling_value = int(filling_value * 1.2) # Increase value by 20%
		filling_success_chance = min(0.9, filling_success_chance + 0.05) # Decrease failure chance, with a minimum of 10%
		message_log.text = "Filling upgraded! Value: %s, Success Chance: %s%%" % [filling_value, filling_success_chance * 100]
	else:
		message_log.text = "Not enough Biscuit Points to upgrade Filling! You need %s." % upgrade_cost
	update_ui()

func _on_sell_biscuits_button_pressed():
	cash += biscuit_points * 2
	biscuit_points = 0
	message_log.text = "Sold all Biscuit Points for $2 each!"
	update_ui()

func buy_item(item):
	var idx = items.find(item)
	if cash > item.cost:
		items[idx].owned += 1
		cash -= item.cost
		for child in items_container.get_children():
			if item == child.item:
				child.item = items[idx]
				update_ui()

func add_item_to_rocket(item):
	var idx = items.find(item)
	if item.owned > 0:
		items[idx].owned -= 1
		add_part(item)
		for child in items_container.get_children():
			if item == child.item:
				child.item = items[idx]
				update_ui()
	
func reset_items_container():
	for child in items_container.get_children():
		child.queue_free()
	for item in items:
		var item_scene = items_scene.instantiate()
		item_scene.custom_minimum_size.y = 142
		items_container.add_child(item_scene)
		item_scene.setup(item)
		update_ui()

func update_items_container():
	for child in items_container.get_children():
		if child.item: child.update()




#region placement

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not obj:
		var placement = OBJ.instantiate()
		add_child(placement)
		placement.global_position = get_global_mouse_position()
		obj = placement
	elif Input.is_action_just_pressed("leftClick") and isValid:
		_place_thing(objectCells)

func _on_grid_gui_input(event: InputEvent) -> void:
	if not obj: return
	var mouse_pos = get_global_mouse_position()
	var newtarget = _get_target_cell_placement(mouse_pos)
	
	if newtarget != targetcell:
		targetcell = newtarget
		obj.global_position = targetcell.global_position + obj.rect.size/2
		
		_reset_highlight()
		objectCells = _get_object_cells()
		isValid = _check_and_highlight_cells(objectCells)

func _get_target_cell_placement(targetPosition):
	for child: Control in grid.get_children():
		if child.get_global_rect().has_point(targetPosition):
			return child
			

func _reset_highlight():
	for child: Control in grid.get_children():
		child.change_color(Color(0.5, 0.5, 0.5, 0.5))
		

#check if placement is valid or if theres another part in the way
func _get_object_cells():
	var cells = []
	for child: Control in grid.get_children():
		if child.get_global_rect().intersects(obj.get_global_rect()):
			cells.append(child)
	return cells

func _check_and_highlight_cells(objectCells: Array):
	var isValid = true
	var objectCellCount = (obj.rect.size.x / gridSize.x) * (obj.rect.size.y / gridSize.y)
	
	if objectCellCount != objectCells.size():
		isValid = false
	
	for cell in objectCells:
		if cell.full:
			isValid = false
			cell.change_color(Color.CRIMSON)
		else:
			cell.change_color(Color.SEA_GREEN)
	return isValid

func _place_thing(objectCells):
	obj.set_on_place()
	obj = null
	isValid = null
	
	for cell in objectCells:
		cell.full = true
	
	_reset_highlight()
#endregion
