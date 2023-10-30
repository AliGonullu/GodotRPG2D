extends Node2D

@onready var sprites :Array = $Sprites.get_children()
var direction

func _ready() -> void:
	if visible:
		for i in sprites:
			i.play("burn")
	else:
		for i in sprites:
			i.stop()


func _on_visibility_changed() -> void:
	if visible:
		for i in sprites:
			i.play("burn")
	else:
		for i in sprites:
			i.stop()
