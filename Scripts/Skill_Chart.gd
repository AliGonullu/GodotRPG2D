extends Node2D

var spellCasts = SpellCasts.new()
var saveLoad = SaveLoad.new()
var playerData = Player_Data.new()
var inventory_visibility :bool
static var vig_cost :int = 1
static var str_cost :int = 1
static var dex_cost :int = 1
static var mana_cost :int = 1
static var eng_cost :int = 1
	

func _on_str_inc_button_up():
	if Items.SkillPoints >= str_cost:
		Items.SkillPoints -= str_cost
		str_cost += 1
		button_action(str_cost, "Strength",$STR/STRLabel, $STR/STRReqLabel, "")

func _on_dex_inc_button_up():
	if Items.SkillPoints >= dex_cost:
		Items.SkillPoints -= dex_cost
		dex_cost += 1
		button_action(dex_cost, "Dexterity", $DEX/DEXLabel, $DEX/DEXReqLabel, "")
	
func _on_mana_inc_button_up():
	if Items.SkillPoints >= mana_cost:
		Items.SkillPoints -= mana_cost
		mana_cost += 1
		button_action(mana_cost, "Mana", $MANA/MANALabel, $MANA/MANAReqLabel, "")
	
func _on_vig_inc_button_up():
	if Items.SkillPoints >= vig_cost:
		Items.SkillPoints -= vig_cost
		vig_cost += 1
		button_action(vig_cost, "Vigor", $VIG/VIGLabel, $VIG/VIGReqLabel, "Health")
	
func _on_eng_inc_button_up():
	if Items.SkillPoints >= eng_cost:
		Items.SkillPoints -= eng_cost
		eng_cost += 1
		button_action(eng_cost, "Energy", $ENG/ENGLabel, $ENG/ENGReqLabel, "Stamina")
	
func button_action(skill_cost, stat_name, stat_label, stat_req_label, stat_bar_type):
	match stat_name:
		"Vigor":
			playerData.vigor += 1
			stat_label.text = stat_name + " : " + str(playerData.vigor)
		"Energy":
			playerData.energy += 1
			stat_label.text = stat_name + " : " + str(playerData.energy)
		"Strength":
			playerData.strength += 1
			stat_label.text = stat_name + " : " + str(playerData.strength)
		"Mana":
			playerData.mana += 1
			stat_label.text = stat_name + " : " + str(playerData.mana)
		"Dexterity":
			playerData.dexterity += 1
			stat_label.text = stat_name + " : " + str(playerData.dexterity)
	
	saveLoad.save_data(saveLoad.SAVE_DIR + saveLoad.SAVE_FILE_NAME)
	stat_req_label.text = "Skill Cost : " + str(skill_cost)
	$SkillPointLabel.text = "Skill Points : " + str(Items.SkillPoints)
	spellCasts.player.StatCalculations(true, spellCasts.player.health_bar, spellCasts.player.stamina_bar, spellCasts.player.attack_idx, clamp(randi_range(1, 6) + (playerData.strength * 2), 1, 500), 275)
	GlobalSignals.stat_bar_changed.emit(stat_bar_type)
	GlobalSignals.send_to_inventory.emit(null, 0)


func _ready():
	visible = false
	GlobalSignals.connect("open_inventory", inventory_open)
	GlobalSignals.connect("close_inventory", inventory_close)
	

func _process(_delta):
	if inventory_visibility:
		visible = false
		
	if Input.is_action_just_pressed("Skill_Chart"):
		if !visible:
			visible = true
			GlobalSignals.close_inventory.emit()
		else:
			visible = false


func inventory_open():
	inventory_visibility = true
	
func inventory_close():
	inventory_visibility = false


func _on_timer_timeout():
	$SkillPointLabel.text = "Skill Points : " + str(Items.SkillPoints)
	$VIG/VIGLabel.text = "Vigor : " + str(playerData.vigor)
	$STR/STRLabel.text = "Strength : " + str(playerData.strength)
	$DEX/DEXLabel.text = "Dexterity : " + str(playerData.dexterity)
	$MANA/MANALabel.text = "Mana : " + str(playerData.mana)
	$ENG/ENGLabel.text = "Energy : " + str(playerData.energy)
