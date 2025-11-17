extends TextureRect

@onready var progresso1 = $ScrollContainer/HBoxContainer/ProgressBar
@onready var progresso2 = $ScrollContainer/HBoxContainer/ProgressBar2
@onready var progresso3 = $ScrollContainer/HBoxContainer/ProgressBar3

var pb = 0
var curr_bar = 0
var main_scene

func setup():
	main_scene = get_tree().current_scene

func update_bar(newscore):
	if newscore <= pb: return
	pb = round(newscore * 100) / 100.
	match curr_bar:
		0:
			if pb > 5:
				curr_bar = 1
				progresso1.value = 5
				progresso2.value = min(20, pb)
				progresso1.get_child(0).hide()
				progresso2.get_child(0).text = str(pb) + "m"
				if pb > 20:
					curr_bar = 2
					progresso2.get_child(0).hide()
					progresso3.value = min(100, pb)
					progresso3.get_child(0).text = str(pb) + "m"
				main_scene.milestone_reached(curr_bar)
			else:
				progresso1.value = pb
				progresso1.get_child(0).text = str(pb) + "m"
			return
		1:
			if pb > 20:
				curr_bar = 2
				progresso2.value = 20
				progresso2.get_child(0).hide()
				progresso3.value = min(100, pb)
				progresso3.get_child(0).text = str(pb) + "m"
				main_scene.milestone_reached(curr_bar)
			else:
				progresso2.value = pb
				progresso2.get_child(0).text = str(pb) + "m"
			return
		2:
			progresso3.value = min(100, pb)
			progresso3.get_child(0).text = str(pb) + "m"
