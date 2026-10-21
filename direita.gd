extends XRController3D

#region var

var activePointedObject = null
var lastRCButton : StaticBody3D
var birth_started := false
var clipboard_instruction_started := false
var _debug_control: Control
var _pranch_local := Transform3D.IDENTITY

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
	# ----------------------- DEBUG -----------------------
	if OS.is_debug_build():
		var canvas = CanvasLayer.new()
		add_child(canvas) # Cria uma camada 2D por cima do mundo 3D
		
		_debug_control = Control.new()
		canvas.add_child(_debug_control)
		_debug_control.set_anchors_preset(Control.PRESET_FULL_RECT) # Faz ocupar a tela toda
		
		# Conecta o sinal nativo de desenho do Control à nossa função
		_debug_control.connect("draw", Callable(self, "_desenhar_mira"))
		_pranch_local = pranch.transform
		pranch.top_level = true
	# --------------------- FIM DEBUG ---------------------
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

# ----------------------- DEBUG -----------------------
const VELOCIDADE_TESTE := 3.0
const ALCANCE_TESTE := 6.0

func _process(delta: float) -> void:
	if not OS.is_debug_build():
		return
	var cam: XRCamera3D = $"../XRCamera3D"

	# Prancheta "na mão": no PC não há controle, então ela fica à frente da câmera
	pranch.global_transform = cam.global_transform * Transform3D(Basis(), Vector3(0.14, -0.45, -0.3)) * _pranch_local

	if is_instance_valid(_debug_control):
		_debug_control.queue_redraw()

	var entrada := Input.get_vector("left", "right", "foward", "backward")
	if entrada == Vector2.ZERO:
		return
	var frente := -cam.global_transform.basis.z
	frente.y = 0.0
	frente = frente.normalized()
	var lado := cam.global_transform.basis.x
	lado.y = 0.0
	lado = lado.normalized()
	var origem: XROrigin3D = get_parent()
	origem.global_position += (lado * entrada.x + frente * -entrada.y) * VELOCIDADE_TESTE * delta
	
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventMouseButton and event.is_pressed():
		var alvo := _mirar()
		if alvo.is_empty():
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			var corpo = alvo["collider"]
			print("Mira em: ", corpo.name)
			if corpo is Interactable:
				activePointedObject = corpo
				lastRCButton = corpo as StaticBody3D
				_on_button_pressed("grip_click")
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			var origem: XROrigin3D = get_parent()
			origem.global_position = alvo["position"]

func _mirar() -> Dictionary:
	var cam: XRCamera3D = $"../XRCamera3D"
	var de := cam.global_position
	var ate := de - cam.global_transform.basis.z * ALCANCE_TESTE
	var consulta := PhysicsRayQueryParameters3D.create(de, ate)
	var corpo := get_node_or_null("../PlayerBody")
	if corpo is CollisionObject3D:
		consulta.exclude = [corpo.get_rid()]
	return get_world_3d().direct_space_state.intersect_ray(consulta)

func _desenhar_mira() -> void:
	if not is_instance_valid(_debug_control):
		return
		
	var centro := _debug_control.get_viewport_rect().size / 2.0
	
	# Usamos _debug_control.draw_line ao invés de tela.draw_line
	_debug_control.draw_line(centro + Vector2(-22, 0), centro + Vector2(22, 0), Color.LIGHT_CYAN, 4.0)
	_debug_control.draw_line(centro + Vector2(0, -22), centro + Vector2(0, 22), Color.LIGHT_CYAN, 4.0)

# --------------------- FIM DEBUG ---------------------

'''/*
func _on_area_3d_area_entered(area: Area3D) -> void:
	print(area.get_overlapping_bodies())
	pass # Replace with function body.
'''
