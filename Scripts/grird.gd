@tool
extends GridContainer
@export var width := 5:
	set(value):
		width = value
		_remove_grid()
		_create_grid()

@export var height := 5:
	set(value):
		height = value
		_remove_grid()
		_create_grid()

@export var cellWidth := 100:
	set(value):
		cellWidth = value
		_remove_grid()
		_create_grid()

@export var cellHeight := 100:
	set(value):
		cellHeight = value
		_remove_grid()
		_create_grid()

@export var seperation := 0:
	set(value):
		seperation = value
		_remove_grid()
		_create_grid()

const GRID_CELL = preload("res://Scene/Gridmap/panel_container.tscn")

func _create_grid():
	add_theme_constant_override("h_separation", seperation)
	add_theme_constant_override("h_separation", seperation)
	
	columns = width
	for i in width * height:
		var gridCellInst = GRID_CELL.instantiate()
		gridCellInst.custom_minimum_size = Vector2(cellWidth, cellHeight)
		add_child(gridCellInst.duplicate())

func _remove_grid():
	for node in get_children():
		node.queue_free()
