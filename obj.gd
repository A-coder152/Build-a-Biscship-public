extends Sprite2D

@export var rect: Rect2
var item
var cells_covered
var neighbors = []
var godot_face = preload("res://icon.svg")
var explosion_scene = preload("res://explosion.tscn")
var explosion_sound = preload("res://nuclear-explosion-386181.mp3")
var scale_tween
var default_scale
var exploded = false
func setup(part: Part):
	item = part
	var dumb = Vector2(item.blocks.x - 1, item.blocks.y - 1)
	texture = item.images[item.upgrade_counter]
	scale = Vector2(item.blocks.x * 1.5, item.blocks.y * 1.5) + dumb * 0.15
	scale.y /= texture.get_height() / 32. * 1.1
	scale.x /= texture.get_width() / 32. * 1.1
	default_scale =scale
	print(scale, texture)
	if texture == godot_face: scale /= 4.0 #LOOOLL????
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

func explode():
	await get_tree().create_timer(randf()).timeout
	var explosion = explosion_scene.instantiate()
	add_child(explosion)
	Sound.play_sfx2(explosion_sound, 0, 1, -2)
	await get_tree().create_timer(1).timeout
	queue_free()
