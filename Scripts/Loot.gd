extends Node2D

var loot_name :String

func _on_area_2d_body_entered(body):
	if loot_name == "Woods":
		GlobalSignals.send_to_inventory.emit(Items.Woods, Items.Woods["Count"])
		queue_free()
