# Parto VR

Protótipo de treinamento de assistência ao parto em realidade virtual,
desenvolvido com Godot 4 e OpenXR para execução em computador e Meta Quest.

## Abrindo o projeto

1. Instale a versão do Godot indicada por `config/features` em `project.godot`.
2. Instale o Blender caso o Godot precise reimportar os arquivos `.blend`.
3. Importe `project.godot` pelo gerenciador de projetos do Godot.
4. Aguarde a primeira importação dos modelos e texturas terminar.
5. Execute `Start.tscn` pelo editor ou exporte pelo preset Android.

A primeira abertura pode demorar porque `.godot/` é um cache local e não faz
parte do repositório. As aberturas seguintes devem ser consideravelmente mais
rápidas.

## Estrutura principal

- `Start.tscn`: cenário e fluxo atual do treinamento.
- `direita.gd`: interação do controle direito e avanço das etapas.
- `blender/bebe.gd`: sequência final do parto.
- `Interact/`: objetos selecionáveis e teleporte.
- `addons/`: Godot XR Tools e plugins OpenXR/Meta.
- `sons/`: narração e efeitos sonoros.

## Exportação para Quest

O preset Android exporta apenas `Start.tscn` e suas dependências. Recursos Meta
que o protótipo ainda não utiliza (rastreamento facial, corporal, ocular, mãos e
passthrough) permanecem desativados para reduzir custo e incompatibilidades.

Artefatos gerados, APKs, caches, downloads ZIP e backups do Blender são
ignorados pelo Git.
