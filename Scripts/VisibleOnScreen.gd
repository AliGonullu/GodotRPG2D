extends VisibleOnScreenNotifier2D

func _on_screen_entered():
	var components = get_parent().get_children()
	for i in components:
		if i.name != name and i.name != "AnimationPlayer" and i.name != "Effects" and !i.name.contains("Timer"):
			i.visible = true


func _on_screen_exited():
	var components = get_parent().get_children()
	for i in components:
		if i.name != name and i.name != "AnimationPlayer" and i.name != "Effects" and !i.name.contains("Timer"):
			i.visible = false
