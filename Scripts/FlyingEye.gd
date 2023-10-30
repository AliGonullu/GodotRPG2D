extends CharacterBase

var player = null
var target_pos :Vector2
var active_anim :String
var direction :String = "Right"

var coolDownTime :float = 1.2

@onready var animPlayer :AnimationPlayer = $AnimationPlayer
@onready var coolDown :Timer = $Timers/CoolDown
@onready var health_bar :Node2D = $HealthBar

var attack_allowed :bool = true
var attack_idx :int = 1


func _ready() -> void:
	ChangeBurnEffect($Effects/CharacterBurnEffect, burned)
	attack_started = false
	ChangeState(IDLE)
	StatAssignment(false, $Hitbox, 1, 4, 1, 1, 1, 10, 0, 10, 5, 5, 5, 630, 300, 900, 1000)
	StatCalculations(false, health_bar, null, attack_idx, randi_range(-4, 4) + (strength * (2 + attack_idx)), 350)
	health_bar.Change_Progress_Bar(max_health, health)
	

func CheckPlayer() -> void:
	if health > 0:
		if player != null:
			target_pos = player.global_position
			
			if global_position.distance_to(target_pos) <= range and attack_allowed:
				if !attack_started:
					direction = "Right" if target_pos.x > global_position.x else "Left"
					ChangeState(ATTACK)
			else:
				if !attack_started and global_position.distance_to(target_pos) > range:
					ChangeState(MOVE)
					direction = "Right" if target_pos.x > global_position.x else "Left"

	if player == null and state == MOVE:
		target_pos = self.global_position
		ChangeState(IDLE)


func _process(delta) -> void:
	CheckPlayer()
	match state:
		IDLE:
			IdleState(delta)
		MOVE:
			MoveState(delta)
		HIT:
			HitState(delta)
		ATTACK:
			AttackState(delta)
		DEATH:
			DeathState(delta)
			
	if animPlayer != null:
		animPlayer.play(active_anim + direction)
	
	move_and_slide()
	
func IdleState(delta) -> void:
	active_anim = "Flight"
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
	
func MoveState(delta) -> void:
	active_anim = "Flight"
	var move_direction = global_position.direction_to(target_pos)#Vector2.RIGHT if target_pos.x > global_position.x else Vector2.LEFT
	velocity = velocity.move_toward(move_direction * speed, acceleration * delta)


func HitState(delta) -> void:
	active_anim = "Hit"
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)


func AttackState(delta) -> void:
	active_anim = "Attack" + str(attack_idx)
	var move_direction = global_position.direction_to(target_pos)
	velocity = velocity.move_toward(move_direction * speed, (friction / 5) * delta)

func DeathState(delta) -> void:
	active_anim = "Death"
	velocity = velocity.move_toward(Vector2.ZERO, (friction / 2) * delta)


func _on_player_detector_body_entered(body) -> void:
	player = body
	GlobalSignals.change_player_detected.emit(true)
	direction = "Right" if player.global_position.x > global_position.x else "Left"
		

func _on_player_detector_body_exited(_body) -> void:
	if player != null:
		GlobalSignals.change_player_detected.emit(false)
		player = null


func _on_hurtbox_area_entered(area) -> void:
	ChangeBurnEffect($Effects/CharacterBurnEffect, burned)
	
	if area.get_parent().direction != null:
		var knockback_vector = Vector2.RIGHT if area.get_parent().direction == "Right" else Vector2.LEFT
		velocity = knockback_vector * area.press_power
		ChangeState(HIT)
		if area.get_parent().direction == direction:
			Change_Bar(false, self, "Health", -area.get_parent().damage * 2, health_bar, Color.WHITE_SMOKE)
		else:
			Change_Bar(false, self, "Health", -area.get_parent().damage, health_bar, Color.WHITE_SMOKE)
	
	if area.get_parent().is_in_group("Fire") or area.is_in_group("Fire"):
		ChangeBurnEffect($Effects/CharacterBurnEffect, true)
		$Timers/BurnTimer.start()
	
	
func ChangeState(_new_state) -> void:
	$Timers/ChangeDirTimer.start(randi_range(3, 8))
	state = _new_state

func AttackAnimStart() -> void:
	attack_started = true
	

func AttackAnimEnd() -> void:
	ChangeState(IDLE)
	attack_allowed = false
	attack_started = false
	attack_idx = 1# if randi_range(1, 10) < 8 else 2
	var new_damage = randi_range(-4, 4) + (strength * (2 + attack_idx))
	damage = clamp(new_damage, 1 , 500)
	coolDown.start(coolDownTime)

func BlockAnimEnd() -> void:
	attack_started = false
	ChangeState(IDLE)
	
func HitAnimEnd() -> void:
	if health <= 0:
		ChangeState(DEATH)
		
	attack_started = false
	ChangeDirection()
	ChangeState(IDLE)

func DeathAnimEnd() -> void:
	global_position.y = 618
	$Sprite2D.global_position.y -= 100
	var loot = enemy_loot.instantiate()
	owner.call_deferred("add_child", loot)
	loot.is_loot = true
	loot.HandleLootChances(2, 5, 85)
	loot.global_position = global_position
	loot.content_count = 2
	
	attack_started = false
	animPlayer.queue_free()
	$AnimationPlayer.queue_free()
	$PlayerDetector.queue_free()
	$Hitbox.queue_free()
	$Hurtbox.queue_free()
	$Timers.queue_free()
	$HealthBar.queue_free()
	$Effects.queue_free()
	set_script(null)


func _on_cool_down_timeout() -> void:
	coolDownTime = randf_range(0.85, 1.25)
	attack_allowed = true

func _on_burn_timer_timeout():
	var fire_damage = self_fire_damage - self_fire_resistance
	Change_Bar(false, self, "Health", -fire_damage, health_bar, Color.CORAL)
	if burn_count > 0:
		$Timers/BurnTimer.start()
		burn_count -= 1
	else:
		ChangeBurnEffect($Effects/CharacterBurnEffect, false)
		burn_count = 5


func _on_change_dir_timer_timeout() -> void:
	if state == IDLE:
		ChangeDirection()
		$Timers/ChangeDirTimer.start(randi_range(3, 8))


func ChangeDirection() -> void:
	if player == null:
		if direction == "Left":
			direction = "Right"
		elif direction == "Right":
			direction = "Left"
		
