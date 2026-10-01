extends AudioStreamPlayer3D
@onready var audio_stream_player_3d_3: AudioStreamPlayer3D = $"."

func _on_finished() -> void:
	audio_stream_player_3d_3.play()
