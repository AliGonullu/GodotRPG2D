extends CharacterBase

var inputVector :Vector2
var attack_idx :int = 1

@onready var remoteTransform :RemoteTransform2D = $RemoteTransform2D
@onready var line :Line2D = $Line2D
@onready var animPlayer :AnimationPlayer = $AnimationPlayer
@onready var inventory :Node2D = $CanvasLayer/Inventory
@onready var health_bar :Node2D = $CanvasLayer/HealthBar
@onready var stamina_bar :Node2D = $CanvasLayer/StaminaBar
@onready var weapon_tile :Node2D = $CanvasLayer/WeaponTile
@onready var usable_tile :Node2D = $CanvasLayer/UsableTile

var cast_type :int #cast:0, throw:1
var active_anim :String = "Idle"
var direction
var allow_spell :bool = true
var allow_gravity :bool = true
var curr_weapon = null

var stamina_recovery_time :float = 0.4

var ui_clicked :bool = false
var detected :bool = false
	
	
func HandleSpell(active_s, cast_t, pos):
	spellCasts.active_spell = active_s
	cast_type = cast_t
	$SpellCastEffect.visible = true
	match cast_type:
		0:
			$SpellCastEffect.spell_type = "Earth"
			spellCasts.CastInstance(owner, spellCasts.active_spell, pos, Vector2.ZERO)
		1: 
			$SpellCastEffect.spell_type = "Fire"
			spellCasts.CastInstance(owner, spellCasts.active_spell, Vector2.ZERO, Vector2.ZERO)
		2:
			$SpellCastEffect.spell_type = "Air"
			spellCasts.CastInstance(owner, spellCasts.active_spell, pos, Vector2.ZERO)
			


func DetectInput():
	inputVector.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	inputVector.y = int(Input.is_action_just_pressed("up"))

	Jump(1100)
	
	if spellCasts.active_spell == null and Input.is_action_just_pressed("One") and allow_spell:
		HandleSpell(stoneWall, 0, get_global_mouse_position())
		allow_spell = false
		$Timers/SpellCoolDown.start()
			
	elif spellCasts.active_spell == null and Input.is_action_just_pressed("Two") and allow_spell:
		HandleSpell(fireball, 1, get_global_mouse_position())
		allow_spell = false
		$Timers/SpellCoolDown.start()
		
	elif spellCasts.active_spell == null and Input.is_action_just_pressed("Three") and allow_spell:
		HandleSpell(air_pulse, 2, $Hitbox/CollisionShape2D.position)
		allow_spell = false
		$Timers/SpellCoolDown.start()
		
	elif spellCasts.active_spell == null and Input.is_action_just_pressed("left_click"):
		if !ui_clicked and curr_weapon != null and weapon_tile.item != null:
			Stamina_Check_And_Attack(curr_weapon["Stamina_Cost"])
	
	else:
		if Input.is_action_pressed("crouch"):
			$UpperCollision.disabled = true
			state = CROUCH
		elif inputVector.x != 0:
			$UpperCollision.disabled = false
			state = MOVE
		else:
			state = IDLE
	
	
func Stamina_Check_And_Attack(_stamina_cost):
	if playerData.stamina >= _stamina_cost and spellCasts.active_spell == null:
		var new_damage
		if curr_weapon["Type"] == "Sword" or curr_weapon["Type"] == "Axe":
			new_damage = randi_range(1, 6) + (playerData.strength * 2) + curr_weapon["Base_Damage"]
			if curr_weapon["Weight"] > 5:
				attack_idx = 2
			elif curr_weapon["Weight"] <= 5:
				attack_idx = 1
				
		elif curr_weapon["Type"] == "Dagger":
			if !detected:
				new_damage = randi_range(1, 6) + (playerData.dexterity * 2) + (curr_weapon["Base_Damage"] * 3)
				attack_idx = 3
			else:
				new_damage = randi_range(1, 6) + (playerData.dexterity * 2) + curr_weapon["Base_Damage"]
				attack_idx = 1 if randi() % 3 == 0 else 3
			
		damage = clamp(new_damage, 1, 500)
		
		if !is_on_floor():
			damage *= 2
			attack_idx = 2
		
		if spellCasts.active_spell == null:
			state = ATTACK
	else:
		AddDamageNumbers(self, "No Stamina", Color.RED)



func Visiblities():
	$Torch.visible = false
	$SpellCastEffect.visible = false
	$CanvasLayer/BloodActiveEffect.visible = false
	$CanvasLayer/FireActiveEffect.visible = false
	$CanvasLayer.visible = true
	$WeaponSprite.visible = false
	
	
func ConnectedSignals():
	GlobalSignals.connect("open_inventory", inventory_open)
	GlobalSignals.connect("close_inventory", inventory_close)
	GlobalSignals.connect("use_from_inventory", use_inventory_item)
	GlobalSignals.connect("send_to_inventory", send_to_inventory)
	GlobalSignals.connect("change_player_detected", change_detected)
	GlobalSignals.connect("stat_bar_changed", refresh_stat_bar)
	
	
func _ready():
	saveLoad.load_data(saveLoad.SAVE_DIR + saveLoad.SAVE_FILE_NAME)
	Visiblities()
	ConnectedSignals()
	weapon_tile.weapon_tile = true
	usable_tile.chest_tile = true
	ChangeBurnEffect($CharacterBurnEffect, burned)
	spellCasts.player = self
	lookVector = Vector2.RIGHT
	Recalculate()
	
	
func Recalculate():
	StatAssignment(true, $Hitbox, playerData.vigor, playerData.strength, playerData.energy, playerData.mana, playerData.dexterity, playerData.self_fire_damage, playerData.self_fire_resistance, playerData.self_bleed_damage, playerData.self_bleed_resistance, 5, 5, 615, 0, 1000, 6000)
	#StatAssignment(true, $Hitbox, 1, 1, 1, 1, 1, 10, 0, 5, 0, 5, 5, 615, 0, 1000, 6000)
	StatCalculations(true, health_bar, stamina_bar, attack_idx, clamp((playerData.strength * 2), 1, 500), 275)
	saveLoad.save_data(saveLoad.SAVE_DIR + saveLoad.SAVE_FILE_NAME)
		
	health_bar.Change_Progress_Bar(playerData.max_health, playerData.health)
	stamina_bar.Change_Progress_Bar(playerData.max_stamina, playerData.stamina)


#SignalFunctions
func refresh_stat_bar(_type):
	saveLoad.load_data(saveLoad.SAVE_DIR + saveLoad.SAVE_FILE_NAME)
	match _type:
		"Health":
			playerData.max_health = playerData.max_health + (playerData.vigor * 10)
			playerData.health = playerData.max_health
			health_bar.Change_Progress_Bar(playerData.max_health, playerData.health)
		"Stamina":
			playerData.max_stamina = playerData.max_stamina + (playerData.energy * 10)
			playerData.stamina = playerData.max_stamina
			stamina_bar.Change_Progress_Bar(playerData.max_stamina, playerData.stamina)

func inventory_open():
	inventory.SetVisible(true)
	
func inventory_close():
	inventory.SetVisible(false)
	
func send_to_inventory(_item, _count):
	StartAllowAttackTimer()
	
func use_inventory_item(_item):
	StartAllowAttackTimer()
	if _item != null:
		if _item["Type"] == "Sword" or _item["Type"] == "Axe" or _item["Type"] == "Dagger":
			Activating_Weapon(_item)
		if _item["Type"] == "Usable":
			match _item["Name"]:
				"Health_Potion":
					Change_Bar(true, self, "Health", _item["Effect_Amount"], health_bar, Color.GREEN)
				"Torch":
					Activating_Item(Items.Torch)
				"CoinPurse":
					GlobalSignals.coin_count_changed.emit(+_item["Count"])
				
				
		
func change_detected(_value):
	detected = _value
	
	
func Activating_Weapon(_item):
	if weapon_tile.item != null:
		GlobalSignals.send_to_inventory.emit(weapon_tile.item, 1)
		weapon_tile.item = null
		weapon_tile.count = 0
		weapon_tile.Load_Sprite_Image()

	curr_weapon = _item
	weapon_tile.item = curr_weapon
	weapon_tile.count = 1
	weapon_tile.Load_Sprite_Image()
	var new_damage
	if curr_weapon["Type"] == "Sword" or curr_weapon["Type"] == "Axe":
		new_damage = randi_range(1, 6) + (strength * 2) + curr_weapon["Base_Damage"]
			
	elif curr_weapon["Type"] == "Dagger":
		if !detected:
			new_damage = randi_range(1, 6) + (dexterity * 2) + (curr_weapon["Base_Damage"] * 3)
			attack_idx = 3
		else:
			new_damage = randi_range(1, 6) + (dexterity * 2) + curr_weapon["Base_Damage"]
			attack_idx = 1 if randi() % 3 == 0 else 3
		
	damage = clamp(new_damage, 1, 500)
	
	
func Activating_Item(_item):
	if usable_tile.item != null:
		GlobalSignals.send_to_inventory.emit(usable_tile.item, 1)
		usable_tile.item = null
		usable_tile.count = 0
		usable_tile.Load_Sprite_Image()

	usable_tile.item = _item
	usable_tile.count = 1
	usable_tile.Load_Sprite_Image()
	
	$Torch.visible = (usable_tile != null and usable_tile.item == Items.Torch)
	
	
func _process(delta):
	
	HandleLineDrawing()
	HandleInputVector()
	
	if allow_gravity:
		ApplyGravity(delta, 25)
	
	
	direction = "Right" if lookVector == Vector2.RIGHT else "Left"
	
	match state:
		IDLE:
			IdleState(delta)
		MOVE:
			MoveState(delta)
		ATTACK:
			AttackState(delta)
		HIT:
			HitState(delta)
		CROUCH:
			CrouchState(delta)
		DEATH:
			DeathState(delta)
	
	animPlayer.play(active_anim + direction)
	

func HandleInputVector():
	if inputVector.x > 0:
		lookVector = Vector2.RIGHT
	elif inputVector.x < 0:
		lookVector = Vector2.LEFT
	
	
func HandleLineDrawing():
	if spellCasts.active_spell != null:
		line.visible = true
		line.set_point_position(0, get_local_mouse_position() - Vector2(0, line.position.y))
	else:
		line.visible = false
		line.set_point_position(0, Vector2.ZERO)
	
	
#States
func IdleState(delta):
	active_anim = "Idle"
	velocity.x = move_toward(velocity.x, 0, friction * delta)
	DetectInput()

func MoveState(delta):
	active_anim = "Run"
	velocity.x = move_toward(velocity.x, inputVector.x * speed, acceleration * delta)
	DetectInput()

func HitState(delta):
	active_anim = "Hit"
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func AttackState(delta):
	velocity.x = move_toward(velocity.x, 0, (friction / 19) * delta)
	active_anim = "Attack" + str(attack_idx)

func CrouchState(delta):
	velocity.x = move_toward(velocity.x, inputVector.x * crouch_speed, acceleration * delta)
	DetectInput()

func DeathState(delta):
	active_anim = "Death"
	velocity.x = move_toward(velocity.x, 0, (friction / 2) * delta)

		
func _on_hurtbox_area_entered(area):
	if area.get_parent().direction != null:
		var set_bleed = !(randi_range(1, 100) > 80)
		bleeding = set_bleed
		Knockback(area, 1)
		Change_Bar(true, self, "Health", -area.get_parent().damage, health_bar, Color.WHITE_SMOKE)
	
	if area.get_parent().is_in_group("Fire") or area.is_in_group("Fire") or burned:
		ChangeBurnEffect($CharacterBurnEffect, true)
		$CanvasLayer/FireActiveEffect.visible = true
		$Timers/BurnTimer.start()
	
	if bleeding:
		$CanvasLayer/BloodActiveEffect.visible = true
		$CanvasLayer/BloodActiveEffect/BleedIcon.visible = true
		$Timers/BleedTimer.start()


func Load_Weapon_Texture():
	if !is_on_floor():
		attack_idx = 2
	$WeaponSprite.scale = Vector2(curr_weapon["Scale"], curr_weapon["Scale"])
	$WeaponSprite.texture = load("res://Sprites/Icons/" + curr_weapon["Name"] + ".png")
	$AnimationPlayer.speed_scale = float(float(3 / curr_weapon["Weight"]) + float(playerData.strength / 10.0))


func StartAllowAttackTimer():
	ui_clicked = true
	$Timers/AllowAttackTimer.start()
	

#AnimationEnds
func AttackAnimEnd():
	Change_Bar(true, self, "Stamina", -curr_weapon["Stamina_Cost"], stamina_bar, Color.WHITE)
	if playerData.stamina != playerData.max_stamina:
		$Timers/StaminaRecoveryTimer.start(stamina_recovery_time)
	state = IDLE
	
func HitAnimEnd():
	state = IDLE

func DeathAnimEnd():
	animPlayer.queue_free()
	$Timers.queue_free()
	$WeaponSprite.queue_free()
	$AnimationPlayer.queue_free()
	$Hitbox.queue_free()
	$Hurtbox.queue_free()
	$CanvasLayer.queue_free()
	set_script(null)
	
	
	
#Timeouts
func _on_allow_attack_timer_timeout():
	$Torch.visible = (usable_tile.item == Items.Torch)
	ui_clicked = false

func _on_stamina_recovery_timer_timeout():
	if playerData.stamina != playerData.max_stamina:
		Change_Bar(true, self, "Stamina", 5, stamina_bar, Color.WHITE)
		$Timers/StaminaRecoveryTimer.start(stamina_recovery_time)
		
func _on_spell_cool_down_timeout():
	allow_spell = true
	
func _on_bleed_timer_timeout():
	var bleed_damage = playerData.self_bleed_damage - playerData.self_bleed_resistance
	Change_Bar(true, self, "Health", -bleed_damage, health_bar, Color.FIREBRICK)
	if bleed_count > 0:
		$Timers/BleedTimer.start()
		bleed_count -= 1
	else:
		bleed_count = 5
		$CanvasLayer/BloodActiveEffect.visible = false
		$CanvasLayer/BloodActiveEffect/BleedIcon.visible = false
		
		
func _on_burn_timer_timeout():
	var fire_damage = playerData.self_fire_damage - playerData.self_fire_resistance
	Change_Bar(true, self, "Health", -fire_damage, health_bar, Color.CORAL)
	if burn_count > 0:
		$Timers/BurnTimer.start()
		burn_count -= 1
	else:
		ChangeBurnEffect($CharacterBurnEffect, false)
		$CanvasLayer/FireActiveEffect.visible = false
		burn_count = 5




#Extras
func Knockback(area, amplifier):
	var knockback_vector = Vector2.RIGHT if area.get_parent().direction == "Right" else Vector2.LEFT
	velocity = knockback_vector * area.press_power * amplifier
	
func Jump(jump_force):
	if !is_on_floor():
		active_anim = "Jump"
	elif inputVector.y != 0:
		velocity.y = -jump_force


func _on_visibility_changed():
	$CanvasLayer.visible = visible

