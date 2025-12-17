extends CharacterBody2D

@onready var hitbox: Area2D = $Hitbox
@onready var detector: Area2D = $Detector
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 20.0

enum EstadoInimigo{
	parado,
	voando
}
var estado_inimigo : EstadoInimigo
var direction =1 


func _ready() -> void:
	preparar_voando()


func _physics_process(delta: float) -> void:
	match estado_inimigo:
		EstadoInimigo.parado:
			estado_parado(delta)
		EstadoInimigo.voando:
			estado_voando(delta)
			
	move_and_slide()


func preparar_parado():
	estado_inimigo = EstadoInimigo.parado
	anim.play("parado")

	
func preparar_voando():
	estado_inimigo = EstadoInimigo.voando
	anim.play("voando")
	
	
func estado_parado(_delta):
	pass
	
func estado_voando(_delta):
	velocity.x += direction * SPEED
	anim.flip_h = direction > 0
	
	
func _on_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"): # Replace with function body.
		print("Player Detectado")
		return

func _on_detector_body_exited(_body: Node2D) -> void:
	pass # Replace with function body.


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(3):
		scale.x *= -1
		direction *= -1
		return
	 
