extends Node2D


var product
var feature :String
static var tmp_inventory 

func _ready() -> void:
	product = Items.Necklace
	feature = Items.Necklace["SaleFeature"]
	
	tmp_inventory = Items.RealInventory
	if tmp_inventory.size() != 0:
		if tmp_inventory[0] != null:
			product = tmp_inventory[0]
			feature = product["SaleFeature"]
			tmp_inventory.pop_at(0)

	$Icon.texture = load("res://Sprites/Icons/" + product["Name"] + ".png")
	$Label.text = feature
