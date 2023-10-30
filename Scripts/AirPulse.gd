extends SpellBase

var direction :String
@onready var animated_sprite :AnimatedSprite2D = $AnimatedSprite2D
@onready var animated_sprite2 :AnimatedSprite2D = $AnimatedSprite2D2

func SetCollisions(value) -> void:
	$CollisionShape2D.disabled = !value
	$Hitbox/CollisionShape2D.disabled = !value

func StatAssignment() -> void:
	$Hitbox.press_power = 850
	damage = 5
	handle = true
	speed = 1500
	acceleration = 1500
	spell_range = 1500
	
func _ready() -> void:
	animated_sprite.frame = 0
	animated_sprite.play("default")
	
	animated_sprite2.frame = 0
	animated_sprite2.play("default")
	
	StatAssignment()
	SetCollisions(false)
	
func _process(delta) -> void:
	if handle:
		look_at(spellCasts.player.global_position)
		Handle()
	else:
		Throw(delta)


func Handle() -> void:
	if Input.is_action_just_pressed("right_click"):
		spellCasts.active_spell = null
		on_queue_free()
	
	modulate.a = 0.5
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("left_click"):
		spellCasts.player.visible = false
		$Timers/LatencyTimer.start()
		$Timers/Timer.start()
		global_position = spellCasts.player.global_position + Vector2(0, -30)
		cast_direction = spellCasts.player.global_position.direction_to(get_global_mouse_position())
		
		spellCasts.player.velocity = -cast_direction * 2 * $Hitbox.press_power
		direction = "Right" if cast_direction.x > cast_direction.y else "Left"
		SetCollisions(true)
		animated_sprite.visible = true
		handle = false
		
		
		
func Throw(delta) -> void:
	modulate.a = 1
	velocity = velocity.move_toward(cast_direction * speed * 10, acceleration * 10 * delta)
	if global_position.distance_to(spellCasts.player.global_position) > spell_range:
		on_queue_free()
	move_and_slide()

func on_queue_free() -> void:
	spellCasts.player.visible = true
	$Timers/Timer.stop()
	queue_free()
	
	
func _on_hitbox_area_entered(area) -> void:
	if area.is_in_group("Hurtbox"):
		on_queue_free()

func _on_hitbox_body_entered(body) -> void:
	if body.name == "Ground":
		on_queue_free()

func _on_timer_timeout() -> void:
	spellCasts.player.visible = true

func _on_latency_timer_timeout() -> void:
	spellCasts.active_spell = null
