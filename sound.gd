extends Node
var musicTween: Tween
var music: AudioStreamPlayer2D
var SFX: AudioStreamPlayer2D
var music_on = true
var sfx_on = true
var music_time
var started = false

func play_music(stream: AudioStream):
	var children = get_children()
	for child in children:
		child.queue_free()
	var music = AudioStreamPlayer2D.new()
	music.stream = stream
	add_child(music)
	music.play()

func play_sfx(stream: AudioStream, pitch: float = 1.0, loudness_adjustment:float = 0.0):
	if !stream:
		print("sfx not connected")
		return
	if !sfx_on:
		return
	SFX = AudioStreamPlayer2D.new()
	print("playing ",  stream)
#	if !SFX.is_playing():
	SFX.stream = stream
	SFX.pitch_scale = pitch
	SFX.volume_db += loudness_adjustment
	add_child(SFX)
	SFX.play()
	await SFX.finished
	if SFX: SFX.queue_free()
