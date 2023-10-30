extends CharacterBody2D
class_name SpellBase

var speed :int
var acceleration :int
var spell_range :int
var damage :int
var handle :bool
var spell :bool = true
var cast_direction :Vector2

var spellCasts = SpellCasts.new()
