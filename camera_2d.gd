extends Camera2D
var noise = FastNoiseLite.new()
var shake_intensity = 0.0
var active_shake_time: float = 0.0
var shake_decay: float = 5.0
var shake_time_speed: float = 20.0
var shake_time: float = 0.0

func _physics_process(delta: float) -> void:
	if active_shake_time > 0:
		shake_time += delta * shake_time_speed
		active_shake_time -= delta
		
		offset = Vector2(
			noise.get_noise_2d(shake_time, 0) * shake_intensity,
			noise.get_noise_2d(0, shake_time) * shake_intensity
		)
		
		shake_intensity = max(shake_intensity, 0.0, shake_decay * delta)
	else:
		offset = lerp(offset, Vector2.ZERO, 10.5 * delta)


func shake_that_ass(intensity: int, time: float):
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0
	
	shake_intensity = intensity
	active_shake_time = time
	shake_time = time
	print("PEE")
