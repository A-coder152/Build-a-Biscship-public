extends Node
var musicTween: Tween
var music: AudioStreamPlayer2D
var SFX: AudioStreamPlayer2D
var SFX2: AudioStreamPlayer2D
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
	music.volume_db += 2
	add_child(music)
	music.play()

func play_sfx(stream: AudioStream, start_from: float = 0.0, pitch: float = 1.0, loudness_adjustment:float = 0.0):
	if !stream:
		print("sfx not connected")
		return
	if !sfx_on:
		return
	if is_instance_valid(SFX): SFX.queue_free()
	SFX = AudioStreamPlayer2D.new()
	print("playing ",  stream)
#	if !SFX.is_playing():
	SFX.stream = stream
	SFX.pitch_scale = pitch
	SFX.volume_db += loudness_adjustment
	add_child(SFX)
	SFX.play(start_from)
	await SFX.finished
	if SFX: SFX.queue_free()
	
func play_sfx2(stream: AudioStream, start_from: float = 0.0, pitch: float = 1.0, loudness_adjustment:float = 0.0):
	if !stream:
		print("sfx not connected")
		return
	if !sfx_on:
		return
	if is_instance_valid(SFX2): SFX2.queue_free()
	SFX2 = AudioStreamPlayer2D.new()
	print("playing ",  stream)
#	if !SFX.is_playing():
	SFX2.stream = stream
	SFX2.pitch_scale = pitch
	SFX2.volume_db += loudness_adjustment
	add_child(SFX2)
	SFX2.play(start_from)
	await SFX2.finished
	if SFX2: SFX2.queue_free()
