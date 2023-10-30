extends Node2D

var loot = load("res://Scenes/Components/loot.tscn")
@onready var health = randi_range(150, 300)
@onready var burn_count = randi_range(4, 10)
@onready var start_burn_timer = $Timers/StartBurningTimer
var first_scale :Vector2

func _ready():
	if randi() % 5 == 0:
		queue_free()
	
	scale.x += randf_range(-0.8, 1)
	scale.y = scale.x + randf_range(-0.8, 1)
	
	z_index = 500 if randi() % 10 == 0 else -50
	first_scale = $Effects.scale
	$Sprite2D.flip_h = (randi() % 2 == 0)
	$Sprite2D.frame = randi_range(0, 3)
	SetBurning(false)
	

func _on_hurtbox_area_entered(area):
	if area.get_parent().name == "Player":
		if area.get_parent().curr_weapon["Type"] == "Axe":
			$AnimationPlayer.play("Hit")
			health -= area.get_parent().damage * 8
			if health <= 0:
				#if !$Effects/CharacterBurnEffect.visible:
				#	pass
				$AnimationPlayer.play("Fall")
	
	if (area.get_parent().is_in_group("Fire") or area.is_in_group("Fire")) and !$Effects.visible:
		if start_burn_timer != null:
			$Effects.set_deferred("visible", true)
			$Effects.scale /= 1.5
			start_burn_timer.start()
		else:
			SetBurning(true)
			$Timers/BurnTimer.start()


func _on_burn_timer_timeout():
	health -= 20
	burn_count -= 1
	
	if burn_count > 0:
		$Timers/BurnTimer.start()
	else:
		SetBurning(false)
		burn_count = randi_range(5, 10)
	
	if health <= 0:
		$AnimationPlayer.play("Fall")


func SetBurning(_value):
	$Effects.set_deferred("visible", _value)
	$Effects/CharacterBurnEffect/Hitbox/CollisionShape2D.set_deferred("disabled", !_value)
	$Effects/CharacterBurnEffect2/Hitbox/CollisionShape2D.set_deferred("disabled", !_value)


var spellCasts = SpellCasts.new()
func FallAnimEnd():
	var wood = spellCasts.CastInstance(get_tree().current_scene, loot, global_position, Vector2(3, 3))
	Items.Woods["Count"] = randi_range(1, 4)
	wood.loot_name = "Woods"
	queue_free()


func _on_start_burning_timer_timeout():
	$Effects.scale = first_scale
	SetBurning(true)
	$Timers/BurnTimer.start()
	$Timers/StartBurningTimer.queue_free()
	start_burn_timer.queue_free()


func _on_tree_detector_area_entered(area):
	if area.get_parent().name == "Tree":
		queue_free()
