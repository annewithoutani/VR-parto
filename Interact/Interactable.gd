extends CollisionObject3D
class_name Interactable

signal interacted(body)

@export var prompt_message := "Interagir"
@export var prompt_input := "inter"
@export var local_to_teleport: Marker3D

@onready var xr_origin_3d: XRToolsStartXR = %XROrigin3D


func get_prompt() -> String:
	var key_name := ""
	for action in InputMap.action_get_events(prompt_input):
		if action is InputEventKey:
			key_name = action.as_text_physical_keycode()
			break

	return prompt_message + "\n[" + key_name + "]"


func interact(body: Node) -> void:
	interacted.emit(body)


func teleport_player() -> void:
	if not is_instance_valid(local_to_teleport):
		push_warning("O objeto interativo '%s' não possui destino de teleporte." % name)
		return

	xr_origin_3d.global_position = local_to_teleport.global_position
