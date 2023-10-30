extends Node2D

func _on_lader_area_body_entered(body):
	if body.on_ladder != null:
		body.on_ladder = true

func _on_lader_area_body_exited(body):
	if body.on_ladder != null:
		body.on_ladder = false
