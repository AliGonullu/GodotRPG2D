extends Node2D

var inventory_tile :bool
var chest_tile :bool
var weapon_tile :bool

var item
var count :int

func _ready():
	if count <= 1:
		$Label.text = ""
	else:
		$Label.queue_free()
		

func _on_button_button_down():
	modulate = Color.DIM_GRAY
	if item == null:
		item = Items.None
		count = 0
		
	if chest_tile:
		GlobalSignals.send_to_inventory.emit(item, count)
		item = null
		count = 0
		Load_Sprite_Image()
	
	elif inventory_tile:
		GlobalSignals.use_from_inventory.emit(item)
		
		if item["Type"] != "Trophy":
			if item["Type"] == "Usable":
				if item["Spend_Conditional"]:
					return
			count -= 1
			if count <= 0:
				item = null
			Load_Sprite_Image()
		
	elif weapon_tile:
		GlobalSignals.send_to_inventory.emit(item, count)
		item = null
		count = 0
		Load_Sprite_Image()
		

func _on_button_button_up():
	modulate = Color.GRAY

func _on_button_mouse_entered():
	modulate = Color.GRAY

func _on_button_mouse_exited():
	modulate = Color.WHITE

func Load_Sprite_Image():
	if item != null and item != Items.None:
		$Sprite2D.texture = load("res://Sprites/Icons/" + item["Name"] + ".png")
		$Label.text = str(count)
	else:
		$Sprite2D.texture = null
		$Label.text = ""
		
	if count <= 1:
		$Label.text = ""
