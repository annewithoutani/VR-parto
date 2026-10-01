extends XRController3D

#region var

var activePointedObject = null
var lastRCButton : StaticBody3D
var birth_started := false
var clipboard_instruction_started := false

@onready var button_prancheta_mesa: Interactable = $"../../Start/Button"
@onready var button_2: Interactable = $"../../Start/Button2"
@onready var button_3: Interactable = $"../../Start/Button3"
@onready var btn_prancheta: Interactable = $"../../Start/btn_prancheta"
@onready var pranch: Node3D = $RightHand/PRANCH
@onready var prancheta: Node3D = $"../../Start/prancheta"
@onready var bebe: Node3D = $"../../Start/bebe"

@onready var aud_3: AudioStreamPlayer = $"../../Start/aud3"
@onready var mulher: AudioStreamPlayer3D = $"../../Start/AudioStreamPlayer3D3"

@onready var enfermeira: Sprite3D = $"../XRCamera3D/enfermeira"
@onready var relogio: Sprite3D = $"../XRCamera3D/relogio"
@onready var roupa: Sprite3D = $"../XRCamera3D/roupa"
@onready var color: Sprite3D = $"../XRCamera3D/color"
@onready var adorno: Sprite3D = $"../XRCamera3D/adorno"

@onready var mao: Area3D = $grab_collision
@onready var mae: Area3D = $"../../Start/Area3D"
@onready var batimento: AudioStreamPlayer3D = $"../../Start/batimento"

#endregion



func _ready() -> void:
	adorno.modulate.a = 0
	enfermeira.modulate.a = 0
	relogio.modulate.a = 0
	roupa.modulate.a = 0
	bebe.hide();
	#connect("grip_click", btnPressedOnRightCntrler);
	pass;

func _physics_process(_delta: float) -> void:
	if $RayCast3D.is_colliding():
		var c = $RayCast3D.get_collider();
		if c.has_method("teleport_player"):
			lastRCButton = c
		activePointedObject = c
	else:
		activePointedObject = null
		
	var distance_to_patient := mao.global_position.distance_to(mae.global_position)
	if distance_to_patient < 1.0:
		batimento.volume_db = lerpf(-60.0, 6.0, 1.0 - distance_to_patient)
	else:
		batimento.volume_db = -80.0

func _on_button_pressed(name: String) -> void:
	#print(mao.global_position);
	#print(mae.global_position);
	
	#print(mao.global_position.distance_to(mae.global_position));
	#print(name);
	#print(activePointedObject);
	if name=="grip_click":
		if activePointedObject != null:
			if activePointedObject == button_prancheta_mesa or activePointedObject == btn_prancheta:
				_toggle_clipboard()
				return

			if activePointedObject==button_2 || activePointedObject==button_3:
				lastRCButton.teleport_player()
				prancheta.show();
				pranch.hide();
				if activePointedObject == button_3:
					if not clipboard_instruction_started:
						clipboard_instruction_started = true
						await get_tree().create_timer(1.0).timeout
						aud_3.play()
				else:
					_start_birth_sequence()


func _toggle_clipboard() -> void:
	if prancheta.is_visible_in_tree():
		pranch.show()
		prancheta.hide()
	else:
		prancheta.show()
		pranch.hide()


func _start_birth_sequence() -> void:
	if birth_started:
		return

	birth_started = true
	bebe.show()
	if bebe.has_method("start_birth_sequence"):
		bebe.call("start_birth_sequence")

	await get_tree().create_timer(10.0).timeout
	if is_inside_tree() and not mulher.playing:
		mulher.play()

func _on_aud_1_finished() -> void:
	await get_tree().create_timer(7).timeout;
	var tween = create_tween();
	tween.tween_property(adorno, "modulate:a", 1.0, 1);
	tween.tween_property(relogio, "modulate:a", 1.0, 1);
	tween.tween_property(roupa, "modulate:a", 1.0, 1);
	tween.tween_property(enfermeira, "modulate:a", 1.0, 1);

func _on_aud_2_finished() -> void:
	
	var tween = create_tween();
	var tween1 = create_tween();
	var tween2 = create_tween();
	var tween3 = create_tween();
	var tween4 = create_tween();
	tween.tween_property(color, "modulate:a", 0.0, 1);
	tween1.tween_property(adorno, "modulate:a", 0.0, 1);
	tween2.tween_property(relogio, "modulate:a", 0.0, 1);
	tween3.tween_property(roupa, "modulate:a", 0.0, 1);
	tween4.tween_property(enfermeira, "modulate:a", 0.0, 1);
	#color.hide();

#var dist = global_position.distance_to(target.global_position)

'''/*
func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area.get_overlapping_bodies())
	pass # Replace with function body.
'''
