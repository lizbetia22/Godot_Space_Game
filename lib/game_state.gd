extends Node

var is_loading_game:bool = false
var current_level
var current_level_key:String = "level_1"
var player: CharacterBody3D
var enemy: CharacterBody3D
var box_collect:bool = false
var health_kit:bool = false
var card_key:bool = false
var jar_collect:bool = false
var player_dead:bool = false
var player_health:int = 10
