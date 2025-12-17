extends Area2D

@onready var speed: float = 300.0
var direction: Vector2 = Vector2.DOWN


func _physicis_process(delta):
	position += direction * speed * delta
	
func _ready():
	connect("body_entered", _on_body_entered)

func _on_body_entered(body:Node2D):
	if body.is_in_group("Hurtbox"):
		body.anima_morta()
		queue_free()
		
		
func _on_visibility_notifiar_sreen_exited():
	queue_free()
	
func _on_self_destruct_timer_tikmeout() -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void :
	queue_free()
