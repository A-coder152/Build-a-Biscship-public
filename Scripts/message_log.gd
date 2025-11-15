extends RichTextLabel

@export var text_delay: float
@export var fade_out_delay: float
@export var fade_out_duration: float
var fade_tween
var cur_message
var message_counter
func new_message(message):
	if message == cur_message:
		return
	cur_message = message
	if fade_tween:
		fade_tween.kill()
	text = ""
	modulate.a = 255
	for i in message:
		if message != cur_message:
			return
		text = text + i
		await get_tree().create_timer(text_delay).timeout
	await get_tree().create_timer(fade_out_delay)
	fade_out()

func fade_out():
	fade_tween= get_tree().create_tween()
	fade_tween.tween_property(self, "modulate", Color.TRANSPARENT, fade_out_duration)
	
