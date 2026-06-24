extends Node2D

@onready var targets_container: Node2D = $Targets
@export var guardia_bloqueo: Node2D

func _ready() -> void:
	# Apagamos los poderes de forma diferida en el frame 1 para asegurar sincronizacion
	apagar_poderes_iniciales.call_deferred()
	
	if targets_container:
		for target: Node in targets_container.get_children():
			target.tree_exited.connect(_on_target_destroyed)
	else:
		print("Error: No se encontro el nodo contenedor 'Targets'")

func apagar_poderes_iniciales() -> void:
	# Desactivamos el escudo y el ataque del inventario de forma segura
	GameState.set_ability(Enums.PlayerAbilities.ABILITY_A, false)
	GameState.set_ability(Enums.PlayerAbilities.ABILITY_B, false)
	print("Poderes iniciales desactivados. Esperando por el Powerup.")

func _on_target_destroyed() -> void:
	if not is_inside_tree():
		return
	
	check_targets.call_deferred()

func check_targets() -> void:
	if not is_inside_tree():
		return
		
	if targets_container and targets_container.get_child_count() == 0:
		liberar_paso()

func liberar_paso() -> void:
	if guardia_bloqueo and is_instance_valid(guardia_bloqueo):
		guardia_bloqueo.queue_free()
		print("Todos los targets destruidos. El guardia se ha retirado.")
