extends Node2D

@onready var button :Button = $CanvasLayer/Button
var saveLoad = SaveLoad.new()
var playerData = Player_Data.new()


func _ready() -> void:
	button.visible = false
	
func _on_button_button_down() -> void:
	GlobalSignals.insert_to_real_inventory.emit()

func _on_button_button_up() -> void:
	get_tree().change_scene_to_file("res://Scenes/MapScene.tscn")
	
func _on_scene_changer_body_entered(body) -> void:
	button.visible = true

func _on_scene_changer_body_exited(body) -> void:
	button.visible = false



