extends Node2D

@onready var sprites :Array = $Sprites.get_children()
var direction

func _ready() -> void:
	for i in sprites:
		i.play("fire")

func _on_destroy_timer_timeout() -> void:
	queue_free()
