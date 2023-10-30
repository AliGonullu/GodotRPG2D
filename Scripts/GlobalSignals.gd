extends Node

signal open_inventory
signal close_inventory

signal send_to_inventory(_item, _count)
signal use_from_inventory(_item)

signal change_player_detected(_value)

signal coin_count_changed(_value)
signal woods_count_changed(_value)

signal stat_bar_changed(_type)
signal scene_changed

signal insert_to_real_inventory

var last_pos :Vector2 = Vector2.ZERO
