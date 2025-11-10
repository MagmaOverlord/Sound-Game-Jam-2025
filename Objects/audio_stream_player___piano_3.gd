extends AudioStreamPlayer

var volume: float = -80.0

func _process(_delta):
	if $"..".plantTracker[2] :
		if volume < -2.0 :
			volume += 0.1
			volume_db = volume
	else :
		if volume > -80.0 :
			volume -= 0.1
			volume_db = volume
