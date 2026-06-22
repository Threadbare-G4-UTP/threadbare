extends Node2D

# Modifica este número según la cantidad total de mecanismos que pongas en el mapa
@export var total_mecanismos: int = 6 

var mecanismos_activos: int = 0

func _ready() -> void:
	print("Templo del Sol cargado. Mecanismos requeridos: ", total_mecanismos)
	
	# Buscaremos automáticamente todos los mecanismos que coloques en el escenario
	# Para que esto funcione, debemos meter los mecanismos en un grupo llamado "mecanismos"
	for mecanismo in get_tree().get_nodes_in_group(&"mecanismos"):
		mecanismo.completed.connect(_on_mecanismo_solar_activado)

func _on_mecanismo_solar_activado() -> void:
	mecanismos_activos += 1
	print("Mecanismos activos: ", mecanismos_activos, "/", total_mecanismos)
	
	if mecanismos_activos >= total_mecanismos:
		completar_puzle_solar()

func completar_puzle_solar() -> void:
	print("¡Todos los mecanismos solares han sido activados!")
	# Aquí conectaremos la aparición del Núcleo Temporal o la apertura de la puerta
