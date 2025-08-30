extends Node2D

# Game Variables
var biscuit_points = 200
var current_bar = "inventory"

@export var items: Array[Part]

enum WARNINGS {PERFECT, GOOD, UNSTABLE_HIGH, UNSTABLE_LOW, CRITICAL_HIGH, CRITICAL_LOW, UNKNOWN}
var warning_messages = [
	["Engine(s) thrust perfect!", "Engine(s) thrust good!", 
	"Engine(s) thrust high!", "Engine(s) thrust low!", 
	"Engine(s) thrust too high!", "Engine(s) thrust too low!"],
	["", "Fuel tanks present.", "", "", "", "No fuel tanks present!"],
	["Horizontal center of mass perfect!", "Horizontal center of mass good!",
	"Horizontal center of mass right!", "Horizontal center of mass left!",
	"Horizontal center of mass too far right!", "Horizontal center of mass too far left!", "No mass!"],
	["Vertical center of mass perfect!", "Vertical center of mass good!",
	"Vertical center of mass high!", "Vertical center of mass low!",
	"Vertical center of mass too high!", "Vertical center of mass too low!", "No mass!"]
]
var warnings = [5, 5, 6, 6]

var items_scene = preload("res://item_box.tscn")
var upgrades_scene = preload("res://upgrade_box.tscn")

# Rocket Variables
var rocket_parts = []
var parts_obj = []
var rocket_value = 0
var rocket_cost = 0
var rocket_success_chance = 0.0
var rocket_mass = 0.0
var rocket_distance = 0.0

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
var builds = []
var build_sizes = []


# UI Node References
@onready var points_label = $UI/VBoxContainer/PointsLabel
@onready var rocket_value_label = $UI/VBoxContainer/ValueLabel
@onready var fail_chance_label = $UI/VBoxContainer/FailureChanceLabel
@onready var weight_label = $UI/VBoxContainer/WeightLabel
@onready var distance_label = $UI/VBoxContainer/DistanceLabel
@onready var warnings_container = $UI/WarningsContainer
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
	
	if biscuit_points < 4:
		get_tree().change_scene_to_file("res://Scene/UI/temporary_game_over_screen.tscn")
		

func update_ui():
	# Updates all the UI labels with the current game state
	points_label.text = "Biscuit Points: %s" % biscuit_points
	rocket_value_label.text = "Rocket Value: %s" % rocket_value
	fail_chance_label.text = "Rocket Success Chance: %s%%" % (round(rocket_success_chance * 100))
	distance_label.text = "Projected Rocket Distance: %s" % str(round(rocket_distance * 100) / 100.) + "m"
	weight_label.text = "Rocket weight: %s" % str(rocket_mass)
	for i in range(len(warnings_container.get_children())):
		var child = warnings_container.get_child(i)
		print(warnings[i])
		child.text = warning_messages[i][warnings[i]]
		if warnings[i] == 0: child.modulate = Color(0.6, 0.9, 1)
		elif warnings[i] == 1: child.modulate = Color(0.8, 1, 0.8)
		elif warnings[i] in [2, 3]: child.modulate = Color(1, 0.8, 0.7)
		elif warnings[i] > 3: child.modulate = Color(1, 0.7, 0.7)
	update_items_container()

func add_part_to_grid(part):
	var placement = OBJ.instantiate()
	add_child(placement)
	placement.global_position = get_global_mouse_position()
	obj = placement
	obj.setup(part)
	message_log.new_message("Added " + str(part.part_name) + " to grid.")
	# General function to add a part, update cost and failure chance

func update_rocket_values():
	# doing rocket science in one night for a jam game is crazy
	rocket_success_chance = 0
	rocket_mass = 0.0
	rocket_distance = 0.0
	rocket_value = 0.0
	var main_build = builds[0]
	if len(builds) > 1:
		for build in builds:
			if len(build) > len(main_build):
				main_build = build
	var engines = []
	var fuels = []
	for part in main_build:
		rocket_mass += part.item.weight
		rocket_value += part.item.value
		if part.item.type == part.item.TYPE.ENGINE:
			engines.append(part)
		elif part.item.type == part.item.TYPE.FUEL:
			fuels.append(part)
	if not (len(engines) and len(fuels)):
		rocket_success_chance = -1
		warnings = [(sign(len(engines)) - 1) * -5, (sign(len(fuels)) - 1) * -5, 6, 6]
	else:
		warnings = [0, 1, 6, 6]
	print(rocket_mass)
		
	rocket_success_chance += 1
	var engines_thrust = 0
	var fuel_on_rocket = 0
	var one_engine = 1.
	var one_tank = 1.
	for part in engines:
		one_engine *= (1 - part.item.success)
		engines_thrust += part.item.special
	for part in fuels:
		one_tank *= (1 - part.item.success)
		fuel_on_rocket += part.item.special
	if rocket_success_chance > 0: rocket_success_chance *= (1 - one_engine) * (1 - one_tank)
	
	var build_size = build_sizes[builds.find(main_build)]
	var rocket_center = Vector2((build_size[0].x + build_size[0].y) / 2.0, (build_size[1].x + build_size[1].y) / 2.0)
	
	var rocket_center_tracker = Vector2.ZERO
	for part in main_build:
		var part_center_x = (part.cells_covered[0].get_index() % grid.width + part.cells_covered[-1].get_index() % grid.width) / 2.0
		var part_center_y = (part.cells_covered[0].get_index() / grid.width + part.cells_covered[-1].get_index() / grid.width) / 2.0
		rocket_center_tracker += Vector2(part_center_x, part_center_y) * part.item.weight
	rocket_center_tracker /= rocket_mass
	
	if engines_thrust < rocket_mass:
		rocket_success_chance = 0
		warnings[0] = 5
		
	var rocket_radius = rocket_center - Vector2(build_size[0].x, build_size[1].x)
	var off_centerism = rocket_center_tracker.x - rocket_center.x
	var center_factor = off_centerism / rocket_radius.x
	var cooked_by_mass_x = 1 - (abs(center_factor))
	if rocket_success_chance > 0: rocket_success_chance *= cooked_by_mass_x
	print(rocket_radius, " s ", off_centerism, " b ", rocket_center_tracker, " f ", rocket_mass)
	update_warnings(center_factor, 2)
	
	var highest_stable_y = (build_size[1].x * 2. + build_size[1].y * 3.) / 5.
	var lowest_stable_y = (build_size[1].x + build_size[1].y * 4.) / 5.
	var cooked_by_mass_y = 1
	warnings[3] = 0
	if rocket_center_tracker.y < highest_stable_y:
		cooked_by_mass_y = 0.5 * ((rocket_center_tracker.y - build_size[1].x) / (highest_stable_y - build_size[1].x))
		update_warnings((0.5 - cooked_by_mass_y) * 2, 3)
	if rocket_center_tracker.y > lowest_stable_y:
		cooked_by_mass_y = ((build_size[1].y - rocket_center_tracker.y) / (build_size[1].y - lowest_stable_y))
		update_warnings(-(1 - cooked_by_mass_y), 3)
	if rocket_success_chance > 0: rocket_success_chance *= cooked_by_mass_y
	
	if engines_thrust > rocket_mass * 2:
		print("sigma")
		var overthrust_nerf = max((4 - engines_thrust / rocket_mass) / 2., 0)
		update_warnings(1 - overthrust_nerf, 0)
		if rocket_success_chance > 0: rocket_success_chance *= overthrust_nerf
	
	if rocket_success_chance > 0:
		const FUEL_DIST_MULT = 10.
		const DRAG_DIST_MULT = 1
		print(fuel_on_rocket, " b ", engines_thrust)
		rocket_distance = (fuel_on_rocket / engines_thrust) * ((engines_thrust / rocket_mass) - 1) * FUEL_DIST_MULT
		rocket_distance -= (build_size[0].y - build_size[0].x + 1) * DRAG_DIST_MULT
		rocket_distance = max(0, rocket_distance)
		
	#rocket_parts.append(part)
	#if rocket_success_chance:
		#rocket_success_chance *= part.success
	#else:
		#rocket_success_chance = part.success
	#rocket_total_value += part.value
	#rocket_total_probability += part.success
	#rocket_cost += part.cost
	#rocket_value = rocket_total_value * rocket_total_probability / len(rocket_parts) / rocket_success_chance
	#if len(rocket_parts) > 1: rocket_value /= sqrt(len(rocket_parts) - 1)
	update_ui()

func _on_launch_button_pressed():
	if builds.size() == 0:
		message_log.new_message("You need to add parts to your rocket first!")
		return
		
		# Generate a random number between 0 and 1. If it's greater than the failure chance, the launch succeeds.
	if randf() < rocket_success_chance:
		# Launch Success!
		const DIST_POINTS_MULT = 20
		var total_points = round((rocket_distance * DIST_POINTS_MULT * randf_range(0.8, 1.2) + rocket_value) * 100) / 100.
		
		biscuit_points += total_points
		message_log.new_message("Launch SUCCESS! Your rocket reached space and you earned %s Biscuit Points!" % total_points)
	else:
		# Launch Failure
		message_log.new_message("Launch FAILED! The rocket exploded and you lost %s Biscuit Points." % rocket_cost)
	
	# Reset rocket for the next launch
	rocket_parts.clear()
	for obje in parts_obj:
		obje.queue_free()
	for child: Control in grid.get_children():
		child.full = false
	parts_obj = []
	builds = []
	build_sizes = []
	rocket_value = 0
	rocket_cost = 0
	rocket_success_chance = 0.0
	rocket_distance = 0.0
	rocket_mass = 0.0
	warnings = [5, 5, 6, 6]
	
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
		message_log.new_message("Bought " + str(item.part_name) + " for " + str(item.cost) + " Biscuit Points.")
	else:
		message_log.new_message("Cannot afford to buy " + str(item.part_name) + ". It costs " + str(item.cost) + " Biscuit Points.")

func add_item_to_rocket(item):
	var idx = items.find(item)
	if item.owned > 0 and not obj:
		items[idx].owned -= 1
		add_part_to_grid(item)
		for child in items_container.get_children():
			if item == child.item:
				child.item = items[idx]
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		update_ui()
	elif item.owned == 0:
		message_log.new_message("You do not have any of this part! Buy the part before adding to rocket.")
	else:
		message_log.new_message("Another item is being selected!")

func upgrade_value(item):
	var idx = items.find(item)
	if biscuit_points >= item.value_upgrade_cost:
		message_log.new_message("Upgraded value of " + str(item.part_name) + " for " + str(item.value_upgrade_cost) + " Biscuit Points.")
		biscuit_points -= item.value_upgrade_cost
		items[idx].value *= 1.1
		items[idx].value_upgrade_cost *= 1.3
		for child in items_container.get_children():
			if item == child.item:
				child.item = items[idx]
		update_ui()
	else:
		message_log.new_message("Cannot afford to upgrade value of " + str(item.part_name) + ". It costs " + str(item.value_upgrade_cost) + " Biscuit Points.")

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
		message_log.new_message("Cannot afford to upgrade success rate of " + str(item.part_name) + ". It costs " + str(item.success_upgrade_cost) + " Biscuit Points.")
	
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

func update_warnings(factor, idx):
	if factor == 0: warnings[idx] = 0
	elif abs(factor) < 0.12: warnings[idx] = 1
	elif factor > 0.12 and factor < 0.5: warnings[idx] = 2
	elif factor < -0.12 and factor > -0.5: warnings[idx] = 3
	elif factor >= 0.5: warnings[idx] = 4
	elif factor <= -0.5: warnings[idx] = 5


#region placement

#this is for tesitng purposes. Move the function body to whatever function adds the part to rocket
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("leftClick") and isValid:
		print("lefto")
		_place_thing(objectCells)
	elif Input.is_action_just_pressed("leftClick") and obj and not isValid:
		print("invalid placement - destroying object")
		message_log.new_message("Invalid object placement!")
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

	var grid_pos = (targetPosition - grid.global_position) / gridSize
	return get_cell_by_coords(Vector2(int(grid_pos.x), int(grid_pos.y)))
	#print(cell_x, "and",  cell_y)

func get_cell_by_coords(coords):
	var cell_x = coords.x
	var cell_y = coords.y
	if cell_x >= 0 and cell_x < grid.width and cell_y >= 0 and cell_y < grid.height:
		var idx = cell_y * grid.width + cell_x
		#print(idx % grid.width)
		return grid.get_child(idx)
	return null

func get_neighbor_cells(coords):
	var directions = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)]
	var neighbor_cells = []
	for change in directions:
		neighbor_cells.append(get_cell_by_coords(coords + change))
	return neighbor_cells

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

func _get_cell_pos(cell_idx: int) -> Vector2i:
	var column = cell_idx % grid.width
	var row = cell_idx / grid.width 
	return Vector2i(column, row)

func update_build_size(x_vector, y_vector, build_size_list):
	if x_vector.x < build_size_list[0].x:
		build_size_list[0].x = x_vector.x
	if x_vector.y > build_size_list[0].y:
		build_size_list[0].y = x_vector.y
	if y_vector.x < build_size_list[1].x:
		build_size_list[1].x = y_vector.x
	if y_vector.y > build_size_list[1].y:
		build_size_list[1].y = y_vector.y
	return build_size_list

func _place_thing(objectCells):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("thing placed")
	obj.set_on_place()
	obj.cells_covered = objectCells
	parts_obj.append(obj)
	var x_vector = Vector2(objectCells[0].get_index() % grid.width, objectCells[-1].get_index() % grid.width)
	var y_vector = Vector2(objectCells[0].get_index() / grid.width, objectCells[-1].get_index() / grid.width)
	var builds_in = []
	for cell in obj.cells_covered:
		for neighbor in get_neighbor_cells(Vector2(cell.get_index() % grid.width, cell.get_index() / grid.width)):
			if neighbor in obj.cells_covered: continue
			for build in builds:
				if obj in build: continue
				for part in build:
					if neighbor in part.cells_covered:
						build.append(obj)
						builds_in.append(build)
						var build_size_list = update_build_size(x_vector, y_vector, build_sizes[builds.find(build)])
						build_sizes[build.find(build)] = build_size_list
	if len(builds_in) == 0:
		builds.append([obj])
		build_sizes.append([x_vector, y_vector])
	elif len(builds_in) > 1:
		for build in builds_in:
			if build == builds_in[0]: continue
			for part in build:
				if not part in builds_in[0]:
					builds_in[0].append(part)
					var part_x_vector = Vector2(part.cells_covered[0].get_index() % grid.width, part.cells_covered[-1].get_index() % grid.width)
					var part_y_vector = Vector2(part.cells_covered[0].get_index() / grid.width, part.cells_covered[-1].get_index() / grid.width)
					var build_size_list = update_build_size(part_x_vector, part_y_vector, build_sizes[builds.find(builds_in[0])])
					build_sizes[builds.find(builds_in[0])] = build_size_list
			build_sizes.remove_at(builds.find(build))
			builds.erase(build)
	print(build_sizes)
	update_rocket_values()
	message_log.new_message("Added " + str(obj.item.part_name) + " to rocket.")
	obj = null
	isValid = null	
	for cell in objectCells:
		cell.full = true
	_reset_highlight()
#endregion
