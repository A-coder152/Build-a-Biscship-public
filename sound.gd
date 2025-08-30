extends Node


func play_music(stream: AudioStream):
	var children = get_children()
	for child in children:
		child.queue_free()
	var music = AudioStreamPlayer2D.new()
	music.stream = stream
	add_child(music)
	music.play()
