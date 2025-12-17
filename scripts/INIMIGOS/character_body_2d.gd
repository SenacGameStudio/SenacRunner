extends CharacterBody2D


@onready var hit_box: Area2D = $HitBox
@onready var detector_terreno: RayCast2D = $DetectorTerreno
@onready var detector_parede: RayCast2D = $DetectorParede
@onready var detector_player: RayCast2D = $DetectorPlayer
@onready var tiro_position: Node2D = $TiroPosition
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var pode_atirar = true



const SPEED = 20.0
const JUMP_VELOCITY = -400.0
enum EstadoInimigo{
	andando,
	atacando,
	morrendo,
	parado
}

var estado_inimigo: EstadoInimigo
var direction =1

func _ready() -> void:
	preparar_andando()
	
func _physics_process(delta: float) -> void:
	ativar_gravidade(delta)
	
	match estado_inimigo:
		EstadoInimigo.andando:
			estado_andando(delta)
		EstadoInimigo.atacando:
			estado_atacando(delta)
		EstadoInimigo.morrendo:
			estado_morrendo(delta)
		
	move_and_slide()

func preparar_andando():
	estado_inimigo = EstadoInimigo.andando
	anim.play("andando")
	
func preparar_atacando():
	estado_inimigo = EstadoInimigo.atacando
	velocity = Vector2.ZERO
	pode_atirar = true
	anim.play("atacando")
	
func preparar_morrendo():
		estado_inimigo = EstadoInimigo.morrendo
		velocity = Vector2.ZERO
		hit_box.process_mode = Node.PROCESS_MODE_DISABLED
		anim.play("morrendo")
		
func estado_andando(_delta):
	velocity.x = direction * SPEED
	if detector_parede.is_colliding():
		direction *= -1
		scale.x *= -1
		
	if not detector_terreno.is_colliding():
		direction *= -1
		scale.x *= -1
	
	if detector_player.is_colliding():
		preparar_atacando()
		return
		
func estado_morrendo(_delta):
	pass
	
func estado_atacando(_delta):
	if anim.frame==2 and pode_atirar:
		atacar()
		pode_atirar=false

	
func ativar_gravidade(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func atacar():
	var novo_tiro= TIRO.instantiate()
	add_sibling(novo_tiro)
	novo_tiro.position = tiro_position.global_position
	novo_tiro.definir_direction(self.direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	preparar_andando()
	return
