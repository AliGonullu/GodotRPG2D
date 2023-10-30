extends ParallaxBackground

@export var day_speed :float
var day_count :int = 1
var hex_colors :Array = ["1d4bd5", "2c491f", "30211e", "421d22", "0d2a2c", "082933"] 
var change_speed :float = 0.01
var forward : bool
var moon_forward :bool
var moon_flag :bool = true

@onready var sun :Sprite2D = $ParallaxLayer/Sun
@onready var moon :Sprite2D = $ParallaxLayer/Moon
@onready var sun_first_pos :Vector2 = sun.global_position

func _ready() -> void:
	$DirLight.color = hex_colors[randi_range(0, hex_colors.size() - 1)]
	$DirLight.energy = 0
	$Timer.start(10 / day_speed)
	sun.visible = true
	moon.visible = false


func _on_timer_timeout() -> void:
	if $DirLight.energy >= 10:
		$DirLight.energy = 9.9
		forward = false
		
	elif $DirLight.energy >= 6.0:
		if moon_flag:
			moon_forward = true
			moon_flag = false
			moon.global_position = sun_first_pos
			sun.visible = false
			moon.visible = true
		
	elif $DirLight.energy <= 0.0:
		$DirLight.energy = 0.1
		forward = true
		moon_forward = false
		Dawn()
	
	if forward:
		$DirLight.energy += (change_speed / 10) if ($DirLight.energy <= 0.6) else change_speed / 3
		sun.global_position.y += ($DirLight.energy / 3)
	else:
		$DirLight.energy -= change_speed
		
	if moon_forward:
		moon.global_position.y += ($DirLight.energy / 10)
	
	$Timer.start(10 / day_speed)
	

func Dawn() -> void:
	sun.visible = true
	moon.visible = false
	moon_flag = true
	sun.global_position = sun_first_pos
	var selected_color
	if day_count % 4 == 0:
		selected_color = hex_colors[randi_range(0, hex_colors.size() - 1)]
		$DirLight.color = selected_color
	day_count += 1
