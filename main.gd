extends Node2D

# Game Variables
var biscuit_points = 200
var current_bar = "inventory"

# Ingredient Stats
var dough_value = 10
var dough_success_chance = 0.5

var filling_value = 20
var filling_success_chance = 0.6

@export var items: Array[Part]

var items_scene = preload("res://item_box.tscn")
var upgrades_scene = preload("res://upgrade_box.tscn")

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
var last_highlighted_cells = []
var last_hover_cell = null
var hover_update_timer = 0.0
var hover_update_interval = 0.016


# UI Node References
@onready var points_label = $UI/VBoxContainer/PointsLabel
@onready var rocket_value_label = $UI/VBoxContainer/ValueLabel
@onready var fail_chance_label = $UI/VBoxContainer/FailureChanceLabel
@onready var launch_button = $UI/LaunchButton
@onready var message_log = $UI/MessageLog
@onready var items_container = $UI/VBoxContainer/HBoxContainer/VBoxContainer/ScrollContainer/ItemsContainer

func _ready():
	# Initial UI update and connect signals
	reset_items_container()
	update_ui()
	launch_button.connect("pressed", _on_launch_button_pressed)
	
	gridSize = Vector2(grid.cellWidth, grid.cellHeight) / 2.4
	for cell in grid.get_children():
		cell.change_color(Color(0.5, 0.5, 0.5, 0.5))

func _process(delta):
	# added this stupid thing because godot is a fucking bitch
	hover_update_timer += delta
	if hover_update_timer >= hover_update_interval:
		hover_update_timer = 0.0
		_update_hover_effects()

func update_ui():
	# Updates all the UI labels with the current game state
	points_label.text = "Biscuit Points: %s" % biscuit_points
	rocket_value_label.text = "Rocket Value: %s" % rocket_value
	fail_chance_label.text = "Rocket Success Chance: %s%%" % (round(rocket_success_chance * 100))
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
	var placement = OBJ.instantiate()
	add_child(placement)
	placement.global_position = get_global_mouse_position()
	obj = placement
	obj.setup(part)
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
	message_log.text = "Added " + str(part.part_name) + " to rocket."
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
		message_log.text = "Launch FAILED! The rocket exploded and you lost %s Biscuit Points." % rocket_cost
	
	# Reset rocket for the next launch
	rocket_parts.clear()
	rocket_value = 0
	rocket_cost = 0
	rocket_success_chance = 0.0
	rocket_total_value = 0
	rocket_total_probability = 0
	
	update_ui()

func buy_item(item):
	var idx = items.find(item)
	if biscuit_points >= item.cost:
		items[idx].owned += 1
		biscuit_points -= item.cost
		for child in items_container.get_children():
			if item == child.item:
				child.item = items[idx]
		update_ui()
		message_log.text = "Bought " + str(item.part_name) + " for " + str(item.cost) + " Biscuit Points."
	else:
		message_log.text = "Cannot afford to buy " + str(item.part_name) + ". It costs " + str(item.cost) + " Biscuit Points."

func add_item_to_rocket(item):
	var idx = items.find(item)
	if item.owned > 0 and not obj:
		items[idx].owned -= 1
		add_part(item)
		for child in items_container.get_children():
			if item == child.item:
				child.item = items[idx]
		update_ui()
	elif item.owned == 0:
		message_log.text = "You do not have any of this part! Buy the part before adding to rocket."
	else:
		message_log.text = "Another item is being selected!"

func upgrade_value(item):
	var idx = items.find(item)
	if biscuit_points >= item.value_upgrade_cost:
		message_log.text = "Upgraded value of " + str(item.part_name) + " for " + str(item.value_upgrade_cost) + " Biscuit Points."
		biscuit_points -= item.value_upgrade_cost
		items[idx].value *= 1.1
		items[idx].value_upgrade_cost *= 1.3
		for child in items_container.get_children():
			if item == child.item:
				child.item = items[idx]
		update_ui()
	else:
		message_log.text = "Cannot afford to upgrade value of " + str(item.part_name) + ". It costs " + str(item.value_upgrade_cost) + " Biscuit Points."

func upgrade_success(item):
	var idx = items.find(item)
	if biscuit_points >= item.success_upgrade_cost:
		message_log.text = "Upgraded success rate of " + str(item.part_name) + " for " + str(item.success_upgrade_cost) + " Biscuit Points."
		biscuit_points -= item.success_upgrade_cost
		items[idx].success += (1 - item.success) * 0.1
		items[idx].success_upgrade_cost *= 1.1
		for child in items_container.get_children():
			if item == child.item:
				child.item = items[idx]
		update_ui()
	else:
		message_log.text = "Cannot afford to upgrade success rate of " + str(item.part_name) + ". It costs " + str(item.success_upgrade_cost) + " Biscuit Points."
	
func reset_items_container():
	for child in items_container.get_children():
		child.queue_free()
	var scene_used = items_scene if current_bar == "inventory" else upgrades_scene
	for item in items:
		var item_scene = scene_used.instantiate()
		item_scene.custom_minimum_size.y = 142
		items_container.add_child(item_scene)
		item_scene.setup(item)
		update_ui()

func update_items_container():
	for child in items_container.get_children():
		if child.item: child.update()

func change_bar(new_bar):
	if new_bar != current_bar:
		current_bar = new_bar
		reset_items_container()


#region placement

#this is for tesitng purposes. Move the function body to whatever function adds the part to rocket
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("leftClick") and isValid:
		print("lefto")
		_place_thing(objectCells)
	elif Input.is_action_just_pressed("leftClick") and obj and not isValid:
		print("invalid placement - destroying object")
		message_log.text = "Invalid object placement!"
		#obj.queue_free()
		#obj = null
		#isValid = null
		#_reset_highlight()

#RIP GUI INPUT
func _update_hover_effects():
	if not obj:
		return
	var mouse_pos = get_global_mouse_position()
	var newtarget = _get_target_cell_placement(mouse_pos)
	if newtarget != last_hover_cell:
		last_hover_cell = newtarget
		if newtarget:
			obj.global_position = newtarget.global_position + obj.rect.size/2
			_reset_highlight()
			objectCells = _get_object_cells()
			isValid = _check_and_highlight_cells(objectCells)
		else:
			_reset_highlight()
			isValid = false
func _get_target_cell_placement(targetPosition):
#	for child in grid.get_children():
#		if child.get_global_rect().has_point(targetPosition):
#			return child
#			
	var grid_pos = (targetPosition - grid.global_position) / gridSize
	var cell_x = int(grid_pos.x)
	var cell_y = int(grid_pos.y)
	if cell_x >= 0 and cell_x < grid.width and cell_y >= 0 and cell_y < grid.height:
		var idx = cell_y * grid.width + cell_x
		return grid.get_child(idx)
	return null

func _reset_highlight():
	for cell in last_highlighted_cells:
		cell.change_color(Color(0.5, 0.5, 0.5, 0.5))
	last_highlighted_cells.clear()

#check if placement is valid or if theres another part in the way
func _get_object_cells() -> Array:
	var cells = []
	for child: Control in grid.get_children():
		if child.get_global_rect().intersects(obj.get_global_rect()):
			cells.append(child)
	return cells

func _check_and_highlight_cells(objectCells: Array):
	isValid = true
	var objectCellCount = obj.item.blocks.x * obj.item.blocks.y
	
	if objectCellCount != objectCells.size():
		isValid = false
	
	for cell in objectCells:
		if cell.full:
			isValid = false
			cell.change_color(Color.CRIMSON)
		else:
			cell.change_color(Color.SEA_GREEN)
		last_highlighted_cells.append(cell)
	return isValid

func _place_thing(objectCells):
	print("thing placed")
	obj.set_on_place()
	obj = null
	isValid = null
	
	for cell in objectCells:
		cell.full = true
	_reset_highlight()
#endregion
