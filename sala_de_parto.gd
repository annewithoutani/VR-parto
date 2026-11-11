extends Node3D

## Quantas vezes o som do coração toca seguidas (o arquivo dura uns 5 s).
@export var repeticoes_coracao := 3

@onready var timer_espera: Timer = $TimerEspera
@onready var timer_gemido: Timer = $TimerGemido
@onready var timer_nascimento: Timer = $TimerNascimento
@onready var dor_mae: AudioStreamPlayer3D = $AudioStreamPlayer3D3
@onready var batimento: AudioStreamPlayer3D = $batimento
@onready var bebe: Node3D = $bebe

var ja_entrou := false
var doppler_ja_usado := false
var _repeticoes_feitas := 0

func entrar_na_sala() -> void:
	if ja_entrou:
		return
	ja_entrou = true
	timer_espera.start()           # 30 s para usar o doppler

func usar_doppler() -> void:
	if not ja_entrou or doppler_ja_usado:
		return
	doppler_ja_usado = true
	timer_espera.stop()
	_repeticoes_feitas = 0
	batimento.volume_db = 0.0
	batimento.play()

func _on_finished() -> void:
	# ignora um batimento que não veio do doppler
	if not doppler_ja_usado:
		return
	_repeticoes_feitas += 1
	if _repeticoes_feitas < repeticoes_coracao:
		batimento.play()
	else:
		timer_gemido.start()       # 5 s depois, os gemidos

func _on_timer_espera_timeout() -> void:
	doppler_ja_usado = true
	_comecar_gemidos()

func _on_timer_gemido_timeout() -> void:
	_comecar_gemidos()

func _comecar_gemidos() -> void:
	if not dor_mae.playing:
		dor_mae.play()
	timer_nascimento.start()       # 20 s de gemidos

func _on_timer_nascimento_timeout() -> void:
	dor_mae.stop()
	bebe.start_birth_sequence()
