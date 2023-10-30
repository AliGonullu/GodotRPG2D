extends Node2D

var spellCasts = SpellCasts.new()
var fire_modulate :Color = Color("e25822")
var water_modulate :Color = Color("005bdc")
var earth_modulate :Color = Color("1f4000")
var air_modulate :Color = Color("cccbea")

@onready var animated_sprite :AnimatedSprite2D = $AnimatedSprite2D
var spell_type

func _ready():
	$AnimatedSprite2D.frame = 0
	$AnimatedSprite2D.play("default")

func _process(_delta):
	if spell_type == "Fire":
		animated_sprite.modulate = fire_modulate
		$PointLight2D.color = Color.ORANGE_RED
	elif spell_type == "Water":
		animated_sprite.modulate = water_modulate
		$PointLight2D.color = Color.BLUE
	elif spell_type == "Earth":
		animated_sprite.modulate = earth_modulate
		$PointLight2D.color = Color.CHARTREUSE
	elif spell_type == "Air":
		animated_sprite.modulate = air_modulate
		$PointLight2D.color = Color.WHITE_SMOKE
		
	if spellCasts.active_spell == null:
		visible = false


func _on_visibility_changed():
	if !visible:
		$AnimatedSprite2D.stop()
	else:
		$AnimatedSprite2D.play("default")
