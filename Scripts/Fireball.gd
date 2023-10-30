extends SpellBase

const burn_effect :PackedScene = preload("res://Scenes/Effects/BurnEffect.tscn")
var direction :String

var standart_scale :Vector2
var start_scale:Vector2 = Vector2.ZERO

var additional_dmg :float = 0.0

@onready var animated_sprite :AnimatedSprite2D = $AnimatedSprite2D

func SetCollisions(value) -> void:
	$CollisionShape2D.disabled = !value
	$Hitbox/CollisionShape2D.disabled = !value

func StatAssignment() -> void:
	$Hitbox.press_power = 550
	handle = true
	speed = 3000
	acceleration = 1000
	spell_range = 1300
	
	
func _ready() -> void:
	standart_scale = scale
	animated_sprite.visible = false
	animated_sprite.frame = 0
	animated_sprite.play("default")
	
	StatAssignment()
	SetCollisions(false)
	
func _process(delta) -> void:
	if $Sprite2D != null:
		if $Sprite2D.rotation == 360:
			$Sprite2D.rotation = 0
		else:
			$Sprite2D.rotation += 50 * delta
		
	if handle:
		look_at(spellCasts.player.global_position)
		Handle()
	else:
		if scale != standart_scale:
			scale = scale.move_toward(standart_scale, 0.8 * delta)
		Throw(delta)


func Handle() -> void:
	$PointLight2D.visible = false
	
	if Input.is_action_just_pressed("right_click"):
		on_queue_free()
	
	modulate.a = 0.4
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_pressed("left_click"):
		$Timers/Timer.start()
		scale = start_scale
		global_position = spellCasts.player.global_position + Vector2(0, -40)
		cast_direction = spellCasts.player.global_position.direction_to(get_global_mouse_position())
		direction = "Right" if cast_direction.x > cast_direction.y else "Left"
		SetCollisions(true)
		$Timers/LatencyTimer.start()
		animated_sprite.visible = true
		handle = false
		
		
func Throw(delta) -> void:
	$PointLight2D.visible = true
	modulate.a = 1
	velocity = velocity.move_toward(cast_direction * speed, acceleration * delta)
	if global_position.distance_to(spellCasts.player.global_position) > spell_range:
		on_queue_free()
	move_and_slide()


func on_queue_free() -> void:
	spellCasts.active_spell = null
	queue_free()
	

func _on_hitbox_body_entered(body) -> void:
	$Timers/Timer.stop() 
	if body.is_in_group("Ground") or body.name == "Ground":
		spellCasts.CastInstance(body.owner, burn_effect, global_position, Vector2.ZERO)
		on_queue_free()


func _on_hitbox_area_entered(area) -> void:
	$Timers/Timer.stop()
	if area.is_in_group("Hurtbox") or area.name == "Ground":
		area.get_parent().burned = true
		on_queue_free()


func _on_timer_timeout() -> void:
	additional_dmg += 1.7
	damage = 5 + float(additional_dmg * 7)
	$Timers/Timer.start()


func _on_latency_timer_timeout() -> void:
	spellCasts.active_spell = null
