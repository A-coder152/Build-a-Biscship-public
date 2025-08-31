extends Node2D


var tween: Tween
var rocket
var newrocket
@onready var camera_2d: Camera2D = $Camera2D
@onready var node_2d: Node2D = $Node2D/Node2D
@onready var explosion: Node2D = $explosion
@onready var mainscene = get_tree().current_scene
func _ready() -> void:
	rocket = Global.thatrocket
	rocket.position = Vector2(0, 320)
	explosion.reparent(rocket)
	rocket.reparent(self)
	
	if Global.fail:
		not_enough_thrust()
	else:
		successful_launch()
		
	
func not_enough_thrust():
	print("uh oh")
	if tween: tween.kill()
	
	tween = create_tween()
	tween.tween_property(rocket, "position:y", 0, 1.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(rocket, "position:y", 300, 1.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_delay(3)
#	tween.parallel().tween_property(rocket, "global_rotation", 15, 1.2).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE).set_delay(3)
#	dont use above 
	await get_tree().create_timer(5).timeout
	camera_2d.shake_that_ass(8, 0.5)
	get_tree().change_scene_to_file("res://main.tscn")
	rocket.reparent(Global)
	rocket.queue_free()

func explode():
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(rocket, "position:y", -100, 2.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	explosion.show()
	camera_2d.shake_that_ass(8, 9)
	await get_tree().create_timer(0.7).timeout
	explosion.hide()
	get_tree().change_scene_to_file("res://main.tscn")
	rocket.reparent(Global)


func successful_launch():
	print("s")
	tween = create_tween()
	tween.tween_property(rocket, "position:y", -200, 2.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(5).timeout
	get_tree().change_scene_to_file("res://main.tscn")
	rocket.reparent(Global)
	rocket.queue_free()
