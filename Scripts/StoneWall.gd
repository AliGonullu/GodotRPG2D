extends SpellBase

var allow_to_cast :bool = true
var first_color :Color
var _direction 

func SetCollisions(value):
	$CollisionShape2D.disabled = !value
	
func StatAssignment():
	handle = true
	damage = 60
	spell_range = 350
	
func _ready():
	velocity = Vector2.ZERO
	first_color = modulate
	StatAssignment()
	SetCollisions(false)

func _process(_delta):
	if handle:
		HandleSpell()
	else:
		modulate.a = 1
	
	if global_position.distance_to(spellCasts.player.global_position) > spell_range * 4:
		queue_free()
	
	move_and_slide()
	
		
func HandleSpell():
	
	if allow_to_cast == false:
		modulate = Color.RED
	else:
		modulate = first_color
	
	if Input.is_action_just_pressed("right_click"):
		spellCasts.active_spell = null
		queue_free()
	
	if spellCasts.player.global_position.distance_to(get_global_mouse_position()) > spell_range:
		visible = false
	else:
		visible = true
		modulate.a = 0.6
		SetCollisions(false)
		global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("rotate"):
			rotation_degrees += 90
		if Input.is_action_just_pressed("left_click") and allow_to_cast:
			$Timers/LatencyTimer.start()
			$Timers/Timer.start()
			SetCollisions(true)
			handle = false


func _on_timer_timeout():
	queue_free()
	

func _on_hitbox_area_entered(area):
	if area.is_in_group("Hurtbox"):
		queue_free()


func _on_latency_timer_timeout():
	spellCasts.active_spell = null
