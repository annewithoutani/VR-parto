extends AudioStreamPlayer

@onready var aud_4: AudioStreamPlayer = $"."

func _on_aud_3_finished() -> void:
	await get_tree().create_timer(1.0).timeout
	aud_4.play()
