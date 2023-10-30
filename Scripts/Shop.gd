extends Node2D

var saveLoad = SaveLoad.new()

func _on_button_button_up():
	saveLoad.save_data(saveLoad.SAVE_DIR + saveLoad.SAVE_FILE_NAME)
	get_tree().change_scene_to_file("res://Scenes/BargainPart/bargain.tscn")
