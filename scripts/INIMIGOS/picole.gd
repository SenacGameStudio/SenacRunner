extends Area2D

var SPEED = 100
var direction = 1

func _process(delta: float) -> void:
	position.x =+ SPEED * delta * direction
