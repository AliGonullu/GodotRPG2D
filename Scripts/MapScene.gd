extends Node2D

@onready var player = $Player
@onready var button = $CanvasLayer/Button

var target_pos_to_move :Vector2
var speed :float = 4000
var direction :Vector2 = Vector2.ZERO

func _ready():
	player.global_position = GlobalSignals.last_pos
	button.visible = false

func _process(delta):
	if Input.is_action_just_pressed("left_click"):
		target_pos_to_move = get_global_mouse_position()
		if target_pos_to_move.x > player.global_position.x:
			$Player/Sprite2D.flip_h = false
		else:
			$Player/Sprite2D.flip_h = true
		direction = player.global_position.direction_to(target_pos_to_move)
	
	if player.global_position.distance_to(target_pos_to_move) > 10:
		$Player/AnimationPlayer.play("Run")
		player.velocity = direction * speed * delta
	else:
		$Player/AnimationPlayer.play("Idle")
		player.velocity = Vector2.ZERO
		
	player.move_and_slide()


func _on_tree_areas_body_entered(body):
	button.visible = true

func _on_tree_areas_body_exited(body):
	button.visible = false


func _on_button_button_down():
	GlobalSignals.last_pos = player.global_position

func _on_button_button_up():
	get_tree().change_scene_to_file("res://Scenes/CombatScene.tscn")
