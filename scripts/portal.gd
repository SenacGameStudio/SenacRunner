extends Node2D

@export var origem: String = ""
@export var destino: String = ""
@export var distancia: int = 10

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var portais = get_tree().get_nodes_in_group("Portais")
		
		for portal in portais:
			if portal.get("origem"):
				if portal.origem == destino:
					var coordenadas = portal.global_position
					
					var x = coordenadas.x + distancia
					var y = coordenadas.y

					body.position = Vector2(x, y)
