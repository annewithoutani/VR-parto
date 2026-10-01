extends AudioStreamPlayer

@onready var asp: AudioStreamPlayer = $"."

func _on_audio_stream_player_finished() -> void:
	await get_tree().create_timer(1.0).timeout
	asp.play()
