extends Area2D

@onready var main = get_parent()

func _on_body_entered(body) -> void:
	if body.name != main.name:
		if main.handle:
			main.allow_to_cast = false

func _on_body_exited(body) -> void:
	if body.name != main.name:
		if main.handle:
			main.allow_to_cast = true
