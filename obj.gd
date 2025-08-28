extends Sprite2D

@export var rect: Rect2
var item

func setup(part):
	item = part
	var dumb = Vector2(item.blocks.x - 1, item.blocks.y - 1)
	texture = item.image
	scale = Vector2(item.blocks.x * 0.375, item.blocks.y * 0.375) + dumb * 0.0375
	print(scale)
	rect.size = Vector2(item.blocks.x * 20, item.blocks.y * 20) + dumb * 2

func get_global_rect():
	return Rect2(
		global_position - rect.size / 2,
		rect.size
	)

func set_on_place():
	modulate.a = 1
