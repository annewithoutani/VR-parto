extends CSGBox3D
'''
var textos = ["texto um", "texto dois", "texto tres", "texto quatro",""];
var i = 0;

@onready var texto: Label = $"../Player/Head/InteractRay/Texto";
@onready var player: CharacterBody3D = $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	texto.text = "" 
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if player.global_position.z < -1 and i<1:
		texto.text = textos[i];
		i += 1;
		
	if Input.is_action_just_pressed("text") and i != 0:
		if i < 5:
			texto.text = textos[i];
			i += 1;
'''
