extends CanvasLayer


const CHAR_READ_RATE = 0.05
var passavel = false
var frase = [""]
#var frase = ["this text is going to be added","to be addedthis text is going","se vc quiser","tchau"]
var index = 0

@onready var textbox_container = $TextboxContainer
@onready var start = $TextboxContainer/MarginContainer/HBoxContainer/Start
@onready var text = $TextboxContainer/MarginContainer/HBoxContainer/Text
@onready var end = $TextboxContainer/MarginContainer/HBoxContainer/End
@onready var texture_rect = $TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide_textbox()
	add_text(frase[index])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass;

func hide_textbox():	
	start.text = ""
	end.text = ""
	text.text = ""
	textbox_container.hide()
	texture_rect.hide()

func show_textbox():
	textbox_container.show()
	texture_rect.show()
	
func add_text(next_text):
	end.text = ""
	passavel = false
	text.text = next_text
	text.visible_characters = 0
	start.text = "Enfermeira: "
	show_textbox()
	var tween = get_tree().create_tween()
	tween.tween_property(text,"visible_ratio",1, len(next_text)*CHAR_READ_RATE).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.connect("finished",on_tween_finished)

func on_tween_finished():
	passavel = true
	print("Tween done!")
	end.text = "..."
	
func _input(event):
	if event.is_action_pressed("inter") and textbox_container.visible == true and passavel and (len(frase)>index+1):
		index += 1
		add_text(frase[index])
	if event.is_action_pressed("inter") and textbox_container.visible == true and passavel and (len(frase)==index+1):
		hide_textbox()
