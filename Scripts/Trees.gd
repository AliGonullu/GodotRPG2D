extends Node2D

var _Tree :PackedScene = preload("res://Scenes/Components/Tree.tscn")
@onready var start_pos :Vector2 = $InstanceTree.global_position
@onready var inst_scale :Vector2 = $InstanceTree.scale
@onready var tree_count:int = randi_range(6, 15)
var offset_x :int

var spellCasts = SpellCasts.new()

func _ready():
	$InstanceTree.queue_free()
	for i in range(0, tree_count):
		var offset_measure = randi_range(250, 1250)
		var offset_dir = -1 if randi() % 2 == 0 else 1
		offset_x += offset_measure * offset_dir
		spellCasts.CastInstance(owner, _Tree, start_pos + Vector2(offset_x, 0), inst_scale)
	
