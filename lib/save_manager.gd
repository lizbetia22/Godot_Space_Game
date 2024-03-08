class_name SaveManager extends Object

const default_filename: String = "mysave"

func _build():
	return{
		"current_level": GameState.current_level_key,
		"position_x": GameState.player.position.x,
		"position_y": GameState.player.position.y,
		"position_z": GameState.player.position.z,
		"rotation_x": GameState.player.rotation_degrees.x,
		"rotation_y": GameState.player.rotation_degrees.y,
		"rotation_z": GameState.player.rotation_degrees.z,
		"key": GameState.card_key,
		"health": GameState.health_kit,
		"jar": GameState.jar_collect,
		"chest": GameState.box_collect
	}

func save_game():
	var savegame = FileAccess.open("user://"+default_filename, FileAccess.WRITE)
	if(savegame != null):
		savegame.store_line(JSON.stringify(_build()))
		
func load_game():
	var savegame = FileAccess.open("user://"+default_filename, FileAccess.READ)
	if (savegame != null):
		var json:JSON = JSON.new()
		var parse_result = json.parse(savegame.get_line())
		if not(parse_result == OK):
			return
		var data:Dictionary = json.get_data()
		GameState.card_key = data.get("key", GameState.card_key)
		GameState.health_kit = data.get("health", GameState.health_kit)
		GameState.jar_collect = data.get("jar", GameState.jar_collect)
		GameState.box_collect = data.get("chest", GameState.box_collect)
		GameState.player.position.x = data.get("position_x", GameState.player.position.x)
		GameState.player.position.y = data.get("position_y", GameState.player.position.y)
		GameState.player.position.z = data.get("position_z", GameState.player.position.z)
		GameState.current_level_key = data.get("current_level", GameState.current_level_key)
		GameState.player.rotation_degrees.x = data.get("rotation_x", GameState.player.rotation_degrees.x)
		GameState.player.rotation_degrees.y = data.get("rotation_y", GameState.player.rotation_degrees.y)
		GameState.player.rotation_degrees.z = data.get("rotation_z", GameState.player.rotation_degrees.z)
	
