extends Node3D

@onready var label_infos:Label = $HUD/LabelInfos
@onready var menu:Control = $Menu
@onready var hud:Control = $HUD
@onready var button_quit: Button = $Menu/ButtonQuit

@onready var collected_key:Label = $Menu/Control/Label_key
@onready var collected_chest:Label = $Menu/Control/Label_Chest
@onready var collected_jar:Label = $Menu/Control/Label_jar
@onready var collected_health:Label = $Menu/Control/Label_Health

@onready var game_collection_key:TextureRect = $HUD/KeyCard
@onready var game_collection_chest:TextureRect = $HUD/Chest
@onready var game_collection_health:TextureRect = $HUD/Health_kit
@onready var game_collection_jar:TextureRect = $HUD/Jar
@onready var not_items_present:Label = $HUD/Label_not_collected
@onready var health_bar:ProgressBar = $HUD/HealthBar/DamageBar

@onready var collect_sound:AudioStreamPlayer3D = $Sounds/Collect
@onready var teleport_sound:AudioStreamPlayer3D = $Sounds/teleport

var current_level_change = null
var box_to_collect:Box = null
var health_kit_to_collect:HealthKit = null
var key_to_collect: CardKey = null
var jar_to_collect: Jar = null
var save:SaveManager = SaveManager.new()
#var health  = GameState.player_health

func _enter_level(from:String, to:String, use_spawn_point:bool = true):
	if(GameState.card_key):
		game_collection_key.visible	 = true
	else:
		game_collection_key.visible = false	
	if(GameState.box_collect):
		game_collection_chest.visible	 = true
	else:
		game_collection_chest.visible = false	
	if(GameState.health_kit):
		game_collection_health.visible	 = true
	else:
		game_collection_health.visible = false	
	if(GameState.jar_collect):
		game_collection_jar.visible	 = true
	else:
		game_collection_jar.visible = false	
	if (GameState.current_level != null): 
		GameState.current_level.call_deferred("queue_free")
	GameState.current_level = load("res://levels/" + to + ".tscn").instantiate()
	GameState.current_level_key = to
	add_child(GameState.current_level)
	GameState.current_level.process_mode = PROCESS_MODE_PAUSABLE
	if (use_spawn_point):
		for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
			if (spawnpoint.key == from):
				GameState.player.position = spawnpoint.position
				GameState.player.rotation = spawnpoint.rotation     
	
func _input(_event):
	if(not get_tree().paused):
		if Input.is_action_just_pressed("player_interact"):
			if (jar_to_collect != null):
				collect_sound.pitch_scale = randf_range(0.5, 0.6)
				collect_sound.play()
				GameState.jar_collect = true
				game_collection_jar.visible	 = true
				jar_to_collect.queue_free()
			if (key_to_collect != null):
				collect_sound.pitch_scale = randf_range(0.5, 0.6)
				collect_sound.play()
				GameState.card_key = true
				game_collection_key.visible	 = true
				key_to_collect.queue_free()
			if (box_to_collect != null):
				collect_sound.pitch_scale = randf_range(0.5, 0.6)
				collect_sound.play()
				GameState.box_collect = true
				game_collection_chest.visible	 = true
				box_to_collect.queue_free()
			if (health_kit_to_collect != null):
				collect_sound.pitch_scale = randf_range(0.5, 0.6)
				collect_sound.play()
				GameState.health_kit = true
				game_collection_health.visible	 = true
				health_kit_to_collect.queue_free()
			if(current_level_change != null):
				if GameState.card_key == true and GameState.box_collect == true and GameState.health_kit == true and GameState.jar_collect == true:
					_enter_level(GameState.current_level_key, current_level_change.destination, true)
					teleport_sound.pitch_scale = randf_range(0.5, 0.6)
					teleport_sound.play()
	if Input.is_action_just_released("menu"):
		_pause()
	
	
func _ready():
	label_infos.visible = false
	GameState.player = $Player
	if GameState.is_loading_game: 
		save.load_game()
	_enter_level("default", GameState.current_level_key, GameState.player.position == Vector3.ZERO)
	menu.visible = false

func _on_player_interaction_detected(node: Node3D):
	if(node.get_parent() is Jar):
		label_infos.text = tr("Collect jar")
		label_infos.visible = true
		jar_to_collect = node.get_parent()
	if(node.get_parent() is CardKey):
		label_infos.text = tr("Collect key for teleport")
		label_infos.visible = true
		key_to_collect = node.get_parent()
	if(node.get_parent() is HealthKit):
		label_infos.text = tr("Collect first aid kit")
		label_infos.visible = true
		health_kit_to_collect = node.get_parent()
	if(node.get_parent() is Box):
		label_infos.text = tr("Collect Chest")
		label_infos.visible = true
		box_to_collect = node.get_parent()
	if(node.get_parent() is Level_Change):
		if(GameState.card_key and GameState.health_kit and GameState.jar_collect and GameState.box_collect):
			label_infos.text = tr("You can teleport to home")
		else:
			label_infos.text=tr('You need to find all objects in the map for teleport')
		label_infos.visible = true
		current_level_change = node.get_parent()

func _on_player_interaction_detected_end(node):
	label_infos.visible = false
	current_level_change = null

func _pause():
	hud.visible = not hud.visible
	menu.visible = not menu.visible
	if(GameState.card_key):
		collected_key.text = "Collected"
	else:
		collected_key.text = "Not collected" 
	if(GameState.box_collect):
		collected_chest.text = "Collected"
	else:
		collected_chest.text = "Not collected" 
	if(GameState.jar_collect):
		collected_jar.text = "Collected"
	else:
		collected_jar.text = "Not collected"
	if(GameState.health_kit):
		collected_health.text = "Collected"
	else:
		collected_health.text = "Not collected"  
	if get_tree().paused:
		GameState.player.capture_mouse()
	else:
		GameState.player.release_mouse()
		button_quit.grab_focus()
	get_tree().paused = not get_tree().paused


func _on_button_quit_pressed():
	save.save_game()
	get_tree().quit()
	
func _process(delta):
	health_bar.value =  GameState.player_health * 10
	if GameState.card_key == false and GameState.box_collect == false and GameState.health_kit == false and GameState.jar_collect == false:
		not_items_present.text = "Collect items in the map to go home"
		not_items_present.visible = true
	else:
		not_items_present.visible = false


func _on_continue_pressed():
	_pause()


func _on_player_player_dead():
	game_collection_jar.visible	 = false
	game_collection_chest.visible = false
	game_collection_health.visible = false
	game_collection_key.visible = false
	
