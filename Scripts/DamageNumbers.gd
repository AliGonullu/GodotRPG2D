extends Node2D

@onready var label :Label = $DamageNumbersLabel

func _ready() -> void:
	$AnimationPlayer.play("Float")
	
func DamageText(number) -> void:
	$DamageNumbersLabel.text = str(number)

func AnimationEnd() -> void:
	queue_free()

func SetColor(_color) -> void:
	$DamageNumbersLabel.set("theme_override_colors/font_color", _color)
