extends Node2D

var Rusty_Standart_Sword :Dictionary
var Rusty_Heavy_Sword :Dictionary
var Basic_Axe :Dictionary
var Basic_Dagger :Dictionary

var Health_Potion :Dictionary
var Torch :Dictionary

var Skull :Dictionary
var Bone :Dictionary
var Necklace :Dictionary

var None :Dictionary

var Woods :Dictionary
var CoinPurse :Dictionary

var WeaponItems :Array
var UsableItems :Array
var TrophyItems :Array
var AllItems :Array

static var SkillPoints :int = 3
static var Coins :int = 0


static var RealInventory :Array

func insert_into_real_inventory(_array):
	RealInventory.append_array([_array])


func _ready():
	#Weapons
	Rusty_Standart_Sword = {
		"Name" : "Rusty_Standart_Sword",
		"Type" : "Sword",
		"Weight" : 4.3,
		"Base_Damage" : 2.5,
		"Stamina_Cost" : 20,
		"Scale" : 3.25,
		"SaleValue" : randi_range(20, 35),
		"SaleFeature" : "Can Exterminite 1 Card of Your Opponent."
	}
	Rusty_Heavy_Sword = {
		"Name" : "Rusty_Heavy_Sword",
		"Type" : "Sword",
		"Weight" : 10.0,
		"Base_Damage" : 4.5,
		"Stamina_Cost" : 30,
		"Scale" : 3.08,
		"SaleValue" : randi_range(25, 45),
		"SaleFeature" : "Can Exterminite 2 Card of Your Opponent."
	}
	Basic_Axe = {
		"Name" : "Basic_Axe",
		"Type" : "Axe",
		"Weight" : 3.0,
		"Base_Damage" : 1.5,
		"Stamina_Cost" : 15,
		"Scale" : 2.9,
		"SaleValue" : randi_range(5, 15),
		"SaleFeature" : "Can Double Value For a Card."
	}
	Basic_Dagger = {
		"Name" : "Basic_Dagger",
		"Type" : "Dagger",
		"Weight" : 1.5,
		"Base_Damage" : 2.0,
		"Stamina_Cost" : 10,
		"Scale" : 2,
		"SaleValue" : randi_range(10, 25),
		"SaleFeature" : "Can Steal a Card of Your Opponent."
	}
	
	#Usables
	Health_Potion = {
		"Name" : "Health_Potion",
		"Type" : "Usable",
		"Effect_Amount": 15.0,
		"Spend_Conditional" : false,
		"SaleValue" : randi_range(5, 10),
		"SaleFeature" : "No Feature."
	}
	Torch = {
		"Name" : "Torch",
		"Type" : "Usable",
		"Spend_Conditional" : false,
		"SaleValue" : 0,
		"SaleFeature" : "No Feature."
	}
	Woods = {
		"Name" : "Woods",
		"Count" : 0,
		"Type" : "Usable",
		"Spend_Conditional" : true,
		"SaleValue" : randi_range(10, 25),
		"SaleFeature" : "No Feature."
	}
	CoinPurse = {
		"Name" : "CoinPurse",
		"Count" : 0,
		"Type" : "Usable",
		"Spend_Conditional" : false,
		"SaleValue" : 0,
	}
	
	#Trophy
	Skull = {
		"Name" : "Skull",
		"Type" : "Trophy",
		"SaleValue" : randi_range(10, 25),
		"SaleFeature" : "No Feature."
	}
	Bone = {
		"Name" : "Bone",
		"Type" : "Trophy",
		"SaleValue" : randi_range(5, 20),
		"SaleFeature" : "No Feature."
	}
	Necklace = {
		"Name" : "Necklace",
		"Type" : "Trophy",
		"SaleValue" : randi_range(50, 125),
		"SaleFeature" : "No Feature."
	}
	
	None = {
		"Name" : "",
		"Type" : "",
		"Weight" : 0.0,
		"Base_Damage" : 0.0,
		"Stamina_Cost" : 0,
		"Scale" : 0,
		"SaleValue" : 0,
		"SaleFeature" : ""
	}
	
	WeaponItems = [Rusty_Heavy_Sword, Rusty_Standart_Sword, Basic_Dagger, Basic_Axe]
	UsableItems = [Health_Potion, Torch, CoinPurse]
	TrophyItems = [Bone, Skull, Necklace]
	AllItems = [WeaponItems, UsableItems, TrophyItems]


func GetRandomItem():
	var dice = randi_range(1, 200)
	if dice > 180:
		return Rusty_Heavy_Sword
	if dice > 150:
		return Rusty_Standart_Sword
	if dice > 120:
		return Health_Potion
	if dice > 90:
		return Basic_Axe
	if dice > 60:
		return Basic_Dagger


func GetItem(weapon_chance :float, usable_chance :float, trophy_chance :float):
	var dice = randi_range(1, 101)
	var choosen_item = null
	
	if dice < trophy_chance:
		choosen_item = TrophyItems[randi_range(0, TrophyItems.size()-1)]

	if dice < usable_chance:
		choosen_item = UsableItems[randi_range(0, UsableItems.size()-1)]
		
	if dice < weapon_chance:
		choosen_item = WeaponItems[randi_range(0, WeaponItems.size()-1)]
		
	return choosen_item
