extends Sprite2D

@export var rect: Rect2
var item
var cells_covered
var godot_face = preload("res://icon.svg")
var scale_tween
var default_scale
func setup(part):
	item = part
	var dumb = Vector2(item.blocks.x - 1, item.blocks.y - 1)
	texture = item.image
	scale = Vector2(item.blocks.x * 1.5, item.blocks.y * 1.5) + dumb * 0.15
	default_scale =scale
	if texture == godot_face: scale /= 4.0
	print(scale)
	rect.size = Vector2(item.blocks.x * 20, item.blocks.y * 20) + dumb * 2
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", default_scale*1.1,0.1).set_trans(Tween.TRANS_QUINT)
	await scale_tween.finished
func get_global_rect():
	return Rect2(
		global_position - rect.size / 2,
		rect.size
	)

func set_on_place():
	scale_tween = create_tween()
	scale_tween.tween_property(self, "scale", default_scale,0.1).set_trans(Tween.TRANS_QUINT)
	modulate.a = 1
