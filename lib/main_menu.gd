extends Control

@onready var button_new:Button = $"Control/MarginContainer/VBoxContainer/New game"
@onready var button_continue:Button = $Control/MarginContainer/VBoxContainer/Continue

signal button_new_pressed()
signal button_continue_pressed()
signal button_exit_pressed()

func _ready():
	if FileAccess.file_exists("user://mysave"):
		button_continue.grab_focus()
	else:
		button_continue.disabled = true
		button_new.grab_focus()
	

func _on_continue_pressed():
	button_continue_pressed.emit()


func _on_new_game_pressed():
	button_new_pressed.emit()


func _on_exit_pressed():
	button_exit_pressed.emit()
