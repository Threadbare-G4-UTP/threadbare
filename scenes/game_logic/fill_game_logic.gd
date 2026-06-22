# SPDX-FileCopyrightText: The Threadbare Authors
# SPDX-License-Identifier: MPL-2.0
class_name FillGameLogic
extends Node
## Manages the logic of the fill-matching game.
##
## @tutorial: https://github.com/endlessm/threadbare/discussions/1323
##
## This is a piece of the fill-matching mechanic.
## [br][br]
## Grabs the label and optional color of each [FillingBarrel] that exist in the
## current scene, and assigns them as the allowed label/color of the [Projectile]
## that each [ThrowingEnemy] is allowed to throw.
## Each time a [FillingBarrel] is filled, perform the label/color assignment again
## so [ThrowingEnemy]s only throw projectiles that can increase the amount of
## the remaining barrels.
## [br][br]
## Also keep track of the completed [FillingBarrel]s and emit [signal goal_reached]
## when [member barrels_to_win] is reached.

## Emited when [member barrels_completed] reaches [member barrels_to_win].
signal goal_reached

## How many barrels to complete for winning.
@export var barrels_to_win: int = 1

## Whether to start the game logic automatically.
## If false, make sure to call [method start].
@export var autostart: bool = false

## Counter for the completed barrels.
var barrels_completed: int = 0


## Update the allowed labels/colors and tell enemies to start.
func start() -> void:
	_update_allowed_colors()
	get_tree().call_group("throwing_enemy", "start")


func _ready() -> void:
	# Le decimos al código que espere a que todo el mapa esté completamente listo
	if not is_node_ready():
		await ready

	# Ahora que todo el mapa existe de forma segura, buscamos y blindamos a los magos
	var mago_dos: Node = get_parent().find_child("Throwin02gNPC2", true, false)
	if mago_dos:
		mago_dos.remove_from_group("throwing_enemy")
		
	var mago_tres: Node = get_parent().find_child("Throwing03gNPC3", true, false)
	if mago_tres:
		mago_tres.remove_from_group("throwing_enemy")

	# Código original de tus compañeros (No se toca)
	var filling_barrels: Array = get_tree().get_nodes_in_group("filling_barrels")
	barrels_to_win = clampi(barrels_to_win, 0, filling_barrels.size())
	for barrel: FillingBarrel in filling_barrels:
		barrel.completed.connect(_on_barrel_completed)
	if autostart:
		start()


func _update_allowed_colors() -> void:
	var allowed_labels: Array[String] = []
	var color_per_label: Dictionary[String, Color]
	for filling_barrel: FillingBarrel in get_tree().get_nodes_in_group("filling_barrels"):
		if filling_barrel.is_queued_for_deletion():
			continue
		if filling_barrel.label not in allowed_labels:
			allowed_labels.append(filling_barrel.label)
			if not filling_barrel.color:
				continue
			color_per_label[filling_barrel.label] = filling_barrel.color
	for enemy: ThrowingEnemy in get_tree().get_nodes_in_group("throwing_enemy"):
		enemy.allowed_labels = allowed_labels
		enemy.color_per_label = color_per_label


func _on_barrel_completed() -> void:
	barrels_completed += 1
	_update_allowed_colors()
	if barrels_completed < barrels_to_win:
		return
	get_tree().call_group("throwing_enemy", "remove")
	get_tree().call_group("projectiles", "remove")
	goal_reached.emit()
func _on_targets_nuevos_completed() -> void:
	# Buscamos y eliminamos al segundo mago
	var mago_dos: Node = get_parent().find_child("Throwin02gNPC2", true, false)
	if mago_dos and mago_dos.has_method("remove"):
		mago_dos.remove()
	
	# Buscamos y eliminamos al tercer mago
	var mago_tres: Node = get_parent().find_child("Throwing03gNPC3", true, false)
	if mago_tres and mago_tres.has_method("remove"):
		mago_tres.remove()


func _on_target_3_completed() -> void:
	pass # Replace with function body.
