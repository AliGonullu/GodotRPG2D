extends Node2D

@onready var inventory_tiles :Array = $Tiles.get_children()

func _ready() -> void:
	$CoinCount/Label.text = str(Items.Coins)
	GlobalSignals.connect("send_to_inventory", insert_item)
	GlobalSignals.connect("coin_count_changed", coin_changed)
	GlobalSignals.connect("insert_to_real_inventory", insert_into_real_inventory)
	for i in inventory_tiles:
		i.inventory_tile = true
		i.Load_Sprite_Image()
	
	if Items.RealInventory.size() != 0:
		for i in Items.RealInventory:
			if i != null:
				if i[0] != null:
					GlobalSignals.send_to_inventory.emit(i[0], i[1])
	
	visible = false
	
	
func coin_changed(_value):
	Items.Coins += _value
	$CoinCount/Label.text = str(Items.Coins)
	
	
func _process(_delta) -> void:
	if Input.is_action_just_pressed("Inventory"):
		if !visible:
			GlobalSignals.open_inventory.emit()
		else:
			GlobalSignals.close_inventory.emit()
		

var already_have_idx :int = -1

func insert_item(_item, _count) -> void:
	for i in range(0, inventory_tiles.size()):
		if inventory_tiles[i].item == _item:
			already_have_idx = i
			break
		else:
			already_have_idx = -1
	
	if already_have_idx != -1:
		inventory_tiles[already_have_idx].count += _count
		inventory_tiles[already_have_idx].Load_Sprite_Image()
	else:
		for i in inventory_tiles:
			if i.item == null:
				i.item = _item
				i.count = _count
				i.Load_Sprite_Image()
				break
				

func SetVisible(value) -> void:
	visible = value


func insert_into_real_inventory() -> void:
	for i in inventory_tiles:
		if i != null:
			if i.item != null:
				Items.insert_into_real_inventory([i.item, i.count])
