extends CharacterBody3D


var inicio = 0
@export var speed = 8.0
@export var jump = 6.0
@export var accel = 16
@export var sens = 0.5
@export var min_angle = -40
@export var max_angle = 90

@onready var prancheta: Node3D = $Prancheta
@onready var head = $Head
@onready var color: ColorRect = $UI/ColorRect
@onready var adorno: TextureRect = $UI/Control/adorno
@onready var relogio: TextureRect = $UI/Control/relogio
@onready var roupa: TextureRect = $UI/Control/roupa

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_rot : Vector2

func _ready():
	if inicio == 0:
		#color.show();
		inicio = 1;
	
	speed = 8.0
	jump = 6.0
	accel = 16
	sens = 0.5
	min_angle = -80
	max_angle = 90
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump

	var input_dir := Input.get_vector("left", "right", "foward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.z = lerp(velocity.z, 0.0, accel * delta)

	move_and_slide()
	
	head.rotation_degrees.x = look_rot.x
	rotation_degrees.y = look_rot.y

func _input(event):
	if event is InputEventMouseMotion:
		look_rot.y -= (event.relative.x * sens)
		look_rot.x -= (event.relative.y * sens)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)
		



func _on_button_2_interacted(body: Variant) -> void:
	global_position = Vector3(-40,0,-13);
	
	
func _on_button_interacted(body: Variant) -> void:
	if prancheta.is_visible_in_tree():
		prancheta.hide();
	else:
		prancheta.show();
		


func _on_button_3_interacted(body: Variant) -> void:
	global_position = Vector3(-45,0,-4);


func _on_audio_stream_player_2_finished() -> void:
	
	var tween = create_tween();'''
	tween.tween_property(color, "modulate:a", 0.0, 0.5);
	tween.tween_property(adorno, "modulate:a", 0.0, 1);
	tween.tween_property(relogio, "modulate:a", 0.0, 0.5);
	tween.tween_property(roupa, "modulate:a", 0.0, 1);
	#color.hide();'''


func _on_audio_stream_player_finished() -> void:
	
	await get_tree().create_timer(5).timeout;
	var tween = create_tween();'''
	tween.tween_property(adorno, "modulate:a", 1.0, 1/2);
	tween.tween_property(relogio, "modulate:a", 1.0, 0.5);
	tween.tween_property(roupa, "modulate:a", 1.0, 1/2);'''
