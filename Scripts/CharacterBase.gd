extends CharacterBody2D
class_name CharacterBase

var saveLoad = SaveLoad.new()
var playerData = Player_Data.new()

const enemy_loot :PackedScene = preload("res://Scenes/Components/Chest.tscn")
const stoneWall :PackedScene = preload("res://Scenes/Spells/StoneWall.tscn")
const fireball :PackedScene = preload("res://Scenes/Spells/Fireball.tscn")
const air_pulse :PackedScene = preload("res://Scenes/Spells/AirPulse.tscn")
const blood_effect :PackedScene = preload("res://Scenes/Effects/BloodEffect.tscn")

const DamageNumbers :PackedScene = preload("res://Scenes/UI/DamageNumbers.tscn")

var spellCasts = SpellCasts.new()

enum{IDLE, MOVE, ATTACK, BLOCK, HIT, CROUCH, DEATH}
var state = IDLE

var max_health :int
var health :int
var max_stamina :int
var stamina :int

var speed :float
var crouch_speed :float
var acceleration :float
var friction :float

var has_blood :bool = true
var lookVector :Vector2

#exposed effects
var burned :bool = false
var poisoned :bool = false
var bleeding :bool = false

var self_fire_damage :int
var self_fire_resistance :int

var self_bleed_damage :int
var self_bleed_resistance :int

var burn_count :int
var bleed_count :int

#stats
var strength :int
var vigor :int
var energy :int
var mana :int
var dexterity :int

var damage :int
var attack_started :bool
var range :int

#max_health = vigor
#speed = dexterity

func StatAssignment(player_flag, _hitbox, vig, str, _energy, _mana, dex, fire_dmg, fire_res, bleed_dmg, bleed_res, _burn_count, _bleed_count, _press_power, _range, _acceleration, _friction) -> void:
	burn_count = _burn_count
	bleed_count = _bleed_count
	_hitbox.press_power = _press_power
	range = _range
	acceleration = _acceleration
	friction = _friction
	
	if !player_flag:
		vigor = vig
		strength = str
		energy = _energy
		mana = _mana
		dexterity = dex
		self_fire_damage = fire_dmg
		self_fire_resistance = fire_res
		self_bleed_damage = bleed_dmg
		self_bleed_resistance = bleed_res
	else:
		playerData.vigor = vigor
		playerData.strength = strength
		playerData.energy = energy
		playerData.mana = mana
		playerData.dexterity = dexterity
		playerData.self_fire_damage = fire_dmg
		playerData.self_fire_resistance = fire_res
		playerData.self_bleed_damage = bleed_dmg
		playerData.self_bleed_resistance = bleed_res
		saveLoad.save_data(saveLoad.SAVE_DIR + saveLoad.SAVE_FILE_NAME)
		

func StatCalculations(player_flag, _health_bar, _stamina_bar, _attack_idx, _damage, _speed) -> void:
	if !player_flag:
		max_health = clamp(vigor * 20, 25, 1000) 
		health = max_health + (vigor * 10)
		max_health = health
		_health_bar.progress_bar.max_value = max_health
		damage = _damage
		max_stamina = clamp(energy * 20, 25, 1000) 
		stamina = max_stamina + (energy * 2)
		max_stamina = stamina
		if _stamina_bar != null:
			_stamina_bar.progress_bar.max_value = max_stamina
		speed = _speed + ((dexterity + energy) * 2)
	else:
		playerData.max_health = clamp(playerData.vigor * 20, 25, 1000) 
		playerData.health = playerData.max_health + (playerData.vigor * 10)
		playerData.max_health = playerData.health
		_health_bar.progress_bar.max_value = playerData.max_health
		damage = _damage
		playerData.max_stamina = clamp(playerData.energy * 20, 25, 1000) 
		playerData.stamina = playerData.max_stamina + (playerData.energy * 2)
		playerData.max_stamina = playerData.stamina
		if _stamina_bar != null:
			_stamina_bar.progress_bar.max_value = playerData.max_stamina
		saveLoad.save_data(saveLoad.SAVE_DIR + saveLoad.SAVE_FILE_NAME)
		speed = _speed + ((playerData.dexterity + playerData.energy) * 2)

var gravity :float = ProjectSettings.get_setting("physics/2d/default_gravity")

func ApplyGravity(delta, _mass) -> void:
	if not is_on_floor_only():
		velocity.y += gravity * _mass/7 * delta
		gravity += _mass/7
	else:
		gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	
	velocity.x = clamp(velocity.x, -1100, 1100)
	velocity.y = clamp(velocity.y, -2000, 2000)
	move_and_slide()


func Change_Bar(player_flag, character, selector, _change, bar, _color) -> void:
	if !player_flag:
		match selector:
			"Health":
				character.health = clamp(character.health + _change, 0, max_health) 
				bar.Change_Progress_Bar(max_health, character.health)
				if _change != 0:
					AddDamageNumbers(character, _change, _color)
				else:
					AddDamageNumbers(character, "Missed", _color)
				
				if _change < 0:
					if character.health <= 0:
						character.state = DEATH
					else:
						character.state = HIT
						if has_blood:
							spellCasts.CastInstance(character.owner, blood_effect, character.global_position, Vector2.ZERO)
			
			"Stamina":
				character.stamina = clamp(character.stamina + _change, 0, max_stamina)
				bar.Change_Progress_Bar(max_stamina, character.stamina)
	else:
		match selector:
			"Health":
				playerData.health = clamp(playerData.health + _change, 0, playerData.max_health) 
				bar.Change_Progress_Bar(playerData.max_health, playerData.health)
				if _change != 0:
					AddDamageNumbers(character, _change, _color)
				else:
					AddDamageNumbers(character, "Missed", _color)
				
				if _change < 0:
					if playerData.health <= 0:
						character.state = DEATH
					else:
						character.state = HIT
						if has_blood:
							spellCasts.CastInstance(character.owner, blood_effect, character.global_position, Vector2.ZERO)
			
			"Stamina":
				playerData.stamina = clamp(playerData.stamina + _change, 0, playerData.max_stamina)
				bar.Change_Progress_Bar(playerData.max_stamina, playerData.stamina)
	

func ChangeBurnEffect(sprite, value) -> void:
	burned = value
	sprite.visible = burned

func AddDamageNumbers(character, taken_damage, _color) -> void:
	var dmgNumbers = DamageNumbers.instantiate()
	dmgNumbers.SetColor(_color)
	character.owner.add_child(dmgNumbers)
	dmgNumbers.z_index = 10
	dmgNumbers.DamageText(taken_damage)
	dmgNumbers.global_position = character.global_position
