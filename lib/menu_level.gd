extends Node3D

func _ready():
	$AnimationFlamingo.play('flamingo/Wave')
	$Frog/AnimationFrog.play('animation/Wave')
	$Barbara/AnimationBarabara.play('animation/Wave')
	
 
func _on_main_menu_button_new_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_main_menu_button_exit_pressed():
	get_tree().quit()


func _on_main_menu_button_continue_pressed():
	GameState.is_loading_game = true
	get_tree().change_scene_to_file("res://scenes/main.tscn")
