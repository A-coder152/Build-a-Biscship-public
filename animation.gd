extends Node2D

@export var fly_sound: AudioStream
@export var explosion_sound: AudioStream
@export var success_sound: AudioStream

var tween: Tween
var rocket
var newrocket
@onready var camera_2d: Camera2D = $Camera2D
@onready var sprite_2d: Node2D = $Node2D/Sprite2D
@onready var explosion: Node2D = $explosion
@onready var mainscene = get_tree().current_scene
func _ready() -> void:
	rocket = Global.thatrocket
	explosion.reparent(rocket)
	var main_build_size = mainscene.build_sizes[mainscene.main_build_idx]
	explosion.scale = Vector2(5, 5) + Vector2(main_build_size[0].y - main_build_size[0].x, main_build_size[1].y - main_build_size[1].x) * 4
	explosion.position = mainscene.rocket_center_a + Vector2(50, 50)
	rocket.reparent(self)

	if Global.fail:
		not_enough_thrust()
	else:
		successful_launch()
		
	
func not_enough_thrust():
	Sound.play_sfx(fly_sound, 0.8, 1, -3)
	print("uh oh")
	if tween: tween.kill()
	
	tween = create_tween()
	tween.tween_property(rocket, "position:y", -300, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(rocket, "position:y", 180, 1.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_delay(3)
	mainscene.global_position = Vector2.ZERO
#	tween.parallel().tween_property(rocket, "global_rotation", 15, 1.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_delay(3)
#	dont use above
	await get_tree().create_timer(4.25).timeout
	camera_2d.shake_that_ass(8, 0.5)
	Sound.play_sfx(explosion_sound)
	explosion.show()
	await get_tree().create_timer(1.75).timeout
	for child in rocket.get_children():
		child.queue_free()
	rocket.global_position = Vector2.ZERO
	rocket.reparent(mainscene)
	queue_free()

func explode():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(rocket, "position:y", -100, 2.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	explosion.show()
	camera_2d.shake_that_ass(8, 9)
	await get_tree().create_timer(0.7).timeout
	explosion.hide()
	get_tree().change_scene_to_file("res://ui_rework.tscn")
	rocket.reparent(Global)


func successful_launch():
	print("s")
	tween = create_tween()
	Sound.play_sfx(fly_sound, 0.8, 1, -3)
	tween.tween_property(rocket, "position:y", -600, 2.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	mainscene.global_position = Vector2.ZERO
	await get_tree().create_timer(5).timeout
	Sound.play_sfx(success_sound, 0, 1, -5)
	for child in rocket.get_children():
		child.queue_free()
	rocket.global_position = Vector2.ZERO
	rocket.reparent(mainscene)
	queue_free()
