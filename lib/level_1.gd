class_name Level extends Node3D

@export var key:String

@onready var planets = $Deco/Planets
@onready var animation_planet = $Deco/Planets/AnimationPlayer
@onready var animation_planet2 = $Deco/Planets2/AnimationPlayer
@onready var animation_plante = $Deco2/plante/Sketchfab_Scene/AnimationPlayer

func _process(delta):
	animation_planet.play("Scene")
	animation_planet2.play("Scene")
	animation_plante.play("ArmatureAction_002")


