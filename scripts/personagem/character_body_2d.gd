extends CharacterBody2D

@onready var anima: AnimatedSprite2D = $animacao_player
@onready var hitbox: Area2D = $Hitbox
@onready var respawn_timer: Timer = $Timer

const BASE_SPEED: float = 180.0
const SPRINT_SPEED = 350

const JUMP_VELOCITY: float = -400.0
const MAX_JUMP: int = 2


const DEATH_JUMP_VELOCITY: float = -180.0 # Velocidade do pulo da morte (ajuste como quiser)
const DEATH_FALL_GRAVITY: float = 10.0 # Gravidade extra para a queda após o pulo
const DEATH_SCALE_TARGET: float = 100.0 # Escala máxima que o player atingirá
const DEATH_EFFECT_DURATION: float = 7.5 # Duração total do efeito de pulo e queda (ajuste ao seu gosto)

var death_timer_started: bool = false # Flag para controlar o timer da morte
var death_gravity_active: bool = false # Flag para ativar a gravidade especial da morte

var x_input: float

var direction: float = 0
var jump_count: int = 0
var acceleration: float = 400
var deceleration: float = 400
var max_speed: float = BASE_SPEED

enum State {
	idle,
	jump,
	run,
	fall,
	ground,
	hit
}

var state_player: State

func _ready() -> void:
	anima_parado()

func _physics_process(delta: float) -> void:
	match state_player:
		State.idle:
			estado_parado(delta)
		State.fall:
			estado_caindo(delta)
		State.run:
			estado_correndo(delta)
		State.jump:
			estado_pulando(delta)
		State.hit:
			estado_morto(delta)

	move_and_slide()

#Funções de preparar a animação do Player
func anima_parado():
	state_player = State.idle
	anima.play("idle")
	anima.speed_scale = 1.0

func anima_correndo():
	state_player = State.run
	anima.play("run")

func anima_pulando():
	state_player = State.jump
	anima.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func anima_caindo():
	state_player = State.fall
	anima.play("fall")

func anima_morto():
	if state_player == State.hit:
		return

	hitbox.call_deferred("set_process_mode", Node.PROCESS_MODE_DISABLED) # 4.5
	state_player = State.hit

	anima.z_index = 100
	anima.play("hit")
	
	hitbox.set_deferred("monitoring", false) # Desabilita a hitbox
	$CollisionShape2D.set_deferred("disabled", true) # Desabilita a colisão principal
	
	set_process_input(false)
	set_physics_process(true) # Garante que o physics_process continue rodando para o efeito

	velocity = Vector2(0, DEATH_JUMP_VELOCITY) # Um pulo para cima
	death_gravity_active = true # Ativar a gravidade especial para a queda

	respawn_timer.start(DEATH_EFFECT_DURATION)
	death_timer_started = true

#Funcões de estado do Player
func estado_parado(delta):
	ativar_gravidade(delta)
	mover(delta)

	if velocity.x != 0:
		anima_correndo()
		return

	if Input.is_action_just_pressed("pulo"):
		anima_pulando()
		return

func estado_caindo(delta):
	ativar_gravidade(delta)
	mover(delta)

	if Input.is_action_just_pressed("pulo") and can_jump():
		anima_pulando()
		return

	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			anima_parado()
		else:
			anima_correndo()
		return

func estado_pulando(delta):
	ativar_gravidade(delta)
	mover(delta)

	#Pulo variavel
	if is_on_floor():
		if Input.is_action_just_pressed("pulo") and can_jump():
			anima_pulando()
			return
	else:
		if Input.is_action_just_released("pulo") or is_on_ceiling():
			velocity.y *= 0.5

	if velocity.y > 0:
		anima_caindo()
		return

func estado_correndo(delta):
	ativar_gravidade(delta)
	mover(delta)

	var current_speed = abs(velocity.x)
	var speed_ratio = current_speed / BASE_SPEED
	var animation_scale = clamp(speed_ratio, 1.0, 1.5)
	anima.speed_scale = animation_scale

	if velocity.x == 0:
		anima_parado()
		return
	
	if Input.is_action_just_pressed("pulo"):
		anima_pulando()
		return
	
	if not is_on_floor():
		jump_count += 1
		anima_caindo()
		return

func estado_morto(delta):
	ativar_gravidade(delta)

	if death_timer_started:
		var time_elapsed = DEATH_EFFECT_DURATION - respawn_timer.time_left
		var scale_progress = clamp(time_elapsed / DEATH_EFFECT_DURATION, 0.0, 1.0)
		var current_scale = lerp(1.0, DEATH_SCALE_TARGET, scale_progress)
		scale = Vector2(current_scale, current_scale)

		if global_position.y > get_viewport_rect().size.y + 100:
			get_tree().reload_current_scene()
	pass

func mover(delta):
	atualizar_direcao()

	if Input.is_action_pressed("correr"):
		max_speed = SPRINT_SPEED
	else:
		max_speed = BASE_SPEED

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func ativar_gravidade(delta):
	if not is_on_floor():
		if death_gravity_active: # Se a gravidade da morte estiver ativa
			velocity += Vector2(0, DEATH_FALL_GRAVITY * delta * 100.0) # Gravidade mais forte
		else:
			velocity += get_gravity() * delta

func atualizar_direcao():
	direction = Input.get_axis("esquerda", "direita")
	if direction < 0:
		anima.flip_h = true
	elif direction > 0:
		anima.flip_h = false

func can_jump():
	return jump_count < MAX_JUMP

func _on_reload_timer_timeout() -> void:
	set_physics_process(false)

	death_timer_started = false
	death_gravity_active = false
	scale = Vector2(1, 1) # Resetar escala
	anima.z_index = 10

	set_process_input(true) # Reativar input
	
	get_tree().reload_current_scene() # Recarrega a cena para respawn

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Hurtbox"):
		area.get_parent().prepara_hit()
		velocity.y = JUMP_VELOCITY * 0.5
