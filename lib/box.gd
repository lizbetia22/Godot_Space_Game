class_name Box extends Node3D

@onready var box = $"."

func _process(delta):
	box.rotate_y(deg_to_rad(10) * delta)
