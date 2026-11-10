extends Node3D

# NOVO: duração do efeito e direção da cabeça para os pés (no espaço do próprio bebê)
@export var duracao_revelar := 2.0
@export var eixo_cabeca_para_pes := Vector3(0, -1, 0)

@onready var bebe: Node3D = $"."
@onready var mulher: AudioStreamPlayer3D = $"../AudioStreamPlayer3D3"
@onready var choro: AudioStreamPlayer3D = $"choro bebe"

var birth_sequence_started := false

# NOVO: shader que esconde tudo o que está além do plano "limite"
const SHADER_REVELAR := """
shader_type spatial;

uniform sampler2D tex_albedo : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 cor : source_color = vec4(1.0);
uniform float aspereza : hint_range(0.0, 1.0) = 0.8;
uniform float corte_alfa = 0.0;
uniform vec3 direcao = vec3(0.0, -1.0, 0.0);
uniform float limite = -100000.0;

varying float proj;

void vertex() {
	proj = dot((MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz, direcao);
}

void fragment() {
	if (proj > limite) {
		discard;
	}
	vec4 c = texture(tex_albedo, UV) * cor;
	if (c.a < corte_alfa) {
		discard;
	}
	ALBEDO = c.rgb;
	ROUGHNESS = aspereza;
}
"""

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
		Vector3(-22.236, 1.2, -10.98),
		2.0
	)
	_revelar_da_cabeca()   # NOVO (no lugar do bebe.show())

# NOVO ----------------------------------------------------------
func _revelar_da_cabeca() -> void:
	var malhas := bebe.find_children("*", "MeshInstance3D", true, false)
	var direcao := (bebe.global_transform.basis * eixo_cabeca_para_pes).normalized()
	var pos_inicial := bebe.global_position

	# 1) medir o bebê ao longo da direção cabeça -> pés
	var minimo := INF
	var maximo := -INF
	for m in malhas:
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		var caixa := mi.get_aabb()
		for i in 8:
			var d := (mi.global_transform * caixa.get_endpoint(i)).dot(direcao)
			minimo = minf(minimo, d)
			maximo = maxf(maximo, d)

	# 2) trocar os materiais por versões "cortáveis"
	var shader := Shader.new()
	shader.code = SHADER_REVELAR
	var trocas := []
	var materiais := []
	for m in malhas:
		var mi := m as MeshInstance3D
		if mi.mesh == null:
			continue
		for s in mi.mesh.get_surface_count():
			var original := mi.get_active_material(s)
			var mat := ShaderMaterial.new()
			mat.shader = shader
			if original is BaseMaterial3D:
				var b := original as BaseMaterial3D
				if b.albedo_texture:
					mat.set_shader_parameter("tex_albedo", b.albedo_texture)
				mat.set_shader_parameter("cor", b.albedo_color)
				mat.set_shader_parameter("aspereza", b.roughness)
				if b.transparency == BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR:
					mat.set_shader_parameter("corte_alfa", b.alpha_scissor_threshold)
			mat.set_shader_parameter("direcao", direcao)
			mat.set_shader_parameter("limite", minimo - 0.01)   # começa tudo escondido
			trocas.append([mi, s, mi.get_surface_override_material(s)])
			materiais.append(mat)
			mi.set_surface_override_material(s, mat)

	show()

	# 3) mover o plano da cabeça até os pés
	var tween := create_tween()
	tween.tween_method(
		_passo_revelar.bind(materiais, direcao, pos_inicial, minimo - 0.01, maximo + 0.01),
		0.0, 1.0, duracao_revelar)
	await tween.finished

	# 4) devolver os materiais originais
	for t in trocas:
		(t[0] as MeshInstance3D).set_surface_override_material(t[1], t[2])

func _passo_revelar(t: float, materiais: Array, direcao: Vector3, pos_inicial: Vector3, a: float, b: float) -> void:
	# o plano acompanha o bebê enquanto ele desliza
	var deslocamento := (bebe.global_position - pos_inicial).dot(direcao)
	var limite := lerpf(a, b, t) + deslocamento
	for mat in materiais:
		(mat as ShaderMaterial).set_shader_parameter("limite", limite)
