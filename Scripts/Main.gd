extends Node2D

#0 : map
#1 : combat_scene

static var active_scene_idx :int = 0

func _ready():
	GlobalSignals.connect("scene_changed", Check_Scene)
	Check_Scene()
		

func Check_Scene():
	match active_scene_idx:
		0:
			$MapScene.visible = true
			$CombatScene.visible = false
		1:
			$MapScene.visible = false
			$CombatScene.visible = true

func _on_button_button_down():
	GlobalSignals.last_pos = $MapScene.player.global_position
	if active_scene_idx == 0:
		active_scene_idx = 1
	elif active_scene_idx == 1:
		active_scene_idx = 0

func _on_button_button_up():
	GlobalSignals.scene_changed.emit()


func _on_map_scene_visibility_changed():
	$MapScene/CanvasLayer.visible = $MapScene.visible


func _on_combat_scene_visibility_changed():
	$CombatScene/CanvasLayer.visible = $CombatScene.visible
	$CombatScene/WinterForest.visible = $CombatScene.visible
