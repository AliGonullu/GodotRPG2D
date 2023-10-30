extends Node2D
class_name SaveLoad

const SAVE_DIR = "user://saves/"
const SAVE_FILE_NAME = "save.json"
const SECURITY_KEY = "0915048IUC"
static var player_data = Player_Data.new()

func _ready():
	verify_save_dir(SAVE_DIR)

func verify_save_dir(path):
	DirAccess.make_dir_absolute(path)

func save_data(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print(FileAccess.get_open_error())
		return
		
	var data = {
		"player_data" : {
			"max_health" = player_data.max_health,
			"max_stamina" = player_data.max_stamina,
			"health" = player_data.health,
			"stamina" = player_data.stamina,
			"vigor" = player_data.vigor,
			"strength" = player_data.strength,
			"mana" = player_data.mana,
			"energy" = player_data.energy,
			"dexterity" = player_data.dexterity,
			"self_fire_damage" = 0,
			"self_fire_resistance" = 0,
			"self_bleed_damage" = 0,
			"self_bleed_resistance" = 0,
		}
	}
	
	var json_string = JSON.stringify(data, "\t")
	file.store_string(json_string)
	file.close()
	
var data
func load_data(path):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file == null:
			print(FileAccess.get_open_error())
			return
			
		var content = file.get_as_text()
		file.close()
		
		data = JSON.parse_string(content)
		if data == null:
			printerr("Cannot open")
			return
			
		player_data = Player_Data.new()
		player_data.max_health = data.player_data.max_health
		player_data.max_stamina = data.player_data.max_stamina
		player_data.health = data.player_data.health
		player_data.stamina = data.player_data.stamina
		player_data.vigor = data.player_data.vigor
		player_data.strength = data.player_data.strength
		player_data.mana = data.player_data.mana
		player_data.energy = data.player_data.energy
		player_data.dexterity = data.player_data.dexterity
		player_data.self_fire_damage = data.player_data.self_fire_damage
		player_data.self_fire_resistance = data.player_data.self_fire_resistance
		player_data.self_bleed_damage = data.player_data.self_bleed_damage
		player_data.self_bleed_resistance = data.player_data.self_bleed_resistance

			
	else:
		printerr("Cannot open")
	
	
	
