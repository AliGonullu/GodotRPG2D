extends Node2D

var spellCasts = SpellCasts.new()

var chest1_oc :Array = [0, 2]
var chest2_oc :Array = [3, 5]
var weapons :Array = ["Sword", "Axe", "Dagger"]

var chest_idx :int = 0
var curr_chest :Array
var player_in_range :bool = false

@onready var chest_tiles :Array = $ContentCanvas/Content/Tiles.get_children()
@onready var sprite :Sprite2D = $Sprite2D
@onready var content :Node2D = $ContentCanvas/Content

@export var content_count :int

var is_loot :bool = false

func _ready() -> void:
	content.visible = false
	
	content_count = clamp(content_count, 1, 8)
	var x = 0
	for i in chest_tiles:
		x += 1
		if x <= content_count:
			i.chest_tile = true
		else:
			i.queue_free()
	content.visible = (chest_idx == 1)
	curr_chest = chest1_oc
	FillChest()
	
	if is_loot:
		$Sprite2D.queue_free()
		$ContentCanvas/Content/InnerChest.visible = false
		$ContentCanvas/Content/BoneChest.visible = true
		#sprite.visible = false
	else:
		$ContentCanvas/Content/InnerChest.visible = true
		$ContentCanvas/Content/BoneChest.visible = false


func _on_button_button_down() -> void:
	if player_in_range:
		if spellCasts.player != null:
			spellCasts.player.StartAllowAttackTimer()
		#Chest Opened
		if chest_idx == 0:
			chest_idx = 1
			GlobalSignals.open_inventory.emit()
			content.visible = true
		#Chest Closed
		else:
			chest_idx = 0
			GlobalSignals.close_inventory.emit()
			content.visible = false
		
		content.visible = (chest_idx == 1)
		if !is_loot:
			sprite.frame = curr_chest[chest_idx]
	

func _on_player_detector_body_entered(_body) -> void:
	player_in_range = true


func _on_player_detector_body_exited(_body) -> void:
	player_in_range = false
	if chest_idx == 1:
		content.visible = false
		chest_idx = 0
		if !is_loot:
			sprite.frame = curr_chest[chest_idx]
		GlobalSignals.close_inventory.emit()


@export var weapon_chance :int
@export var usable_chance :int
@export var throphy_chance:int

var loot_weapon_chance :int
var loot_usable_chance :int
var loot_throphy_chance:int

func HandleLootChances(weapon_c, usable_c, throphy_c) -> void:
	loot_weapon_chance = weapon_c
	loot_usable_chance = usable_c
	loot_throphy_chance = throphy_c


var weapon_flag :bool = false
func FillChest() -> void:
	var insterted_items :Array
	for i in chest_tiles:
		var selected_item
		
		if !is_loot:
			selected_item = Items.GetItem(weapon_chance, usable_chance, throphy_chance)
		else:
			selected_item = Items.GetItem(loot_weapon_chance, loot_usable_chance, loot_throphy_chance)
			
		if !insterted_items.has(selected_item):
			i.item = selected_item
			insterted_items.append(i.item)
				
		if i.item != null:
#			if i.item["Type"] == "Usable":
#				i.count = randi_range(1, 2)
#				if i.item["Name"] == "CoinPurse":
#					i.item["Count"] = randi_range(10, 40)
			if weapons.has(i.item["Type"]):
				if weapon_flag:
					selected_item = null
					i.item = null
					i.count = 0
				else:
					i.count = 1
					weapon_flag = true
			else:
				i.count = randi_range(1, 2)
				if i.item["Name"] == "CoinPurse":
					i.item["Count"] = randi_range(10, 40)
		i.Load_Sprite_Image()
