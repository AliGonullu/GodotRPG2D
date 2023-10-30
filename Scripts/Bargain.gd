extends Node2D

var card = load("res://Scenes/BargainPart/good_card.tscn")
var card_offset :Vector2 = Vector2(0, 0)

var spellCasts = SpellCasts.new()
var saveLoad = SaveLoad.new()

func _ready() -> void:
	saveLoad.load_data(saveLoad.SAVE_DIR + saveLoad.SAVE_FILE_NAME)
	for i in Items.RealInventory:
		if i != null:
			print("i : ")
			print(i)
			print("---------------\n")
			if i[0] != null:
				print("i[0] : ")
				print(i[0])
				print("---------------\n")
				spellCasts.CastInstance(self, card, $CanvasLayer/CardsPos.global_position + card_offset, Vector2(3, 3))
				card_offset += Vector2(40,0)
				card_offset *= -1
