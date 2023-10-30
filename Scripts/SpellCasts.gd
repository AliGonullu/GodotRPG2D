extends Node2D
class_name SpellCasts

static var player
static var active_spell

func CastInstance(main, instance, cast_pos :Vector2, _scale :Vector2):
	var inst = instance.instantiate()
	main.call_deferred("add_child", inst)
	if cast_pos != Vector2.ZERO:
		inst.global_position = cast_pos
	if _scale != Vector2.ZERO:
		inst.scale = _scale
	return inst
