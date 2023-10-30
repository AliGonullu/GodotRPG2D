extends Node2D

@onready var sprite :Sprite2D = $BloodEffectAnimSprite
func _ready() -> void:
	sprite.frame = 0

func _on_blood_effect_anim_sprite_animation_looped() -> void:
	queue_free()
