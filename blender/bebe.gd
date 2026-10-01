extends Node3D

@onready var bebe: Node3D = $"."
@onready var mulher: AudioStreamPlayer3D = $"../AudioStreamPlayer3D3"
@onready var choro: AudioStreamPlayer3D = $"choro bebe"

var birth_sequence_started := false

# Starts at most once. The previous _process implementation started a new
# 20-second timer every frame and eventually created hundreds of tweens.
func start_birth_sequence() -> void:
	if birth_sequence_started:
		return

	birth_sequence_started = true
	await get_tree().create_timer(20.0).timeout

	if not is_inside_tree():
		return

	mulher.stop()
	if not choro.playing:
		choro.play()

	var tween := create_tween()
	tween.tween_property(
		bebe,
		"global_position",
		Vector3(-22.236, 1.288, -10.38),
		2.0
	)
