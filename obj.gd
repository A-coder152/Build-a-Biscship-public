extends Sprite2D

@export var rect: Rect2
var item
var cells_covered
var godot_face = preload("res://icon.svg")

func setup(part):
	item = part
	var dumb = Vector2(item.blocks.x - 1, item.blocks.y - 1)
	texture = item.image
	scale = Vector2(item.blocks.x * 1.5, item.blocks.y * 1.5) + dumb * 0.15
	if texture == godot_face: scale /= 4.0
	print(scale)
	rect.size = Vector2(item.blocks.x * 20, item.blocks.y * 20) + dumb * 2

func get_global_rect():
	return Rect2(
		global_position - rect.size / 2,
		rect.size
	)

func set_on_place():
	modulate.a = 1
