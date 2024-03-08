extends CharacterBody3D
 
@onready var camera_mout = $camera_mount
@onready var animation_player = $visuals/Flamingo/AnimationPlayer
@onready var visuals = $visuals
@onready var gun = $visuals/Flamingo/CharacterArmature/Skeleton3D/Pistol/Pistol
@onready var raycast = $RayCast3D
@onready var timer = $Timer

@onready var sound_walking: AudioStreamPlayer3D = $Player_sounds/walking
@onready var sound_running: AudioStreamPlayer3D = $Player_sounds/running
@onready var sound_gun: AudioStreamPlayer3D = $Player_sounds/gun
@onready var sound_death: AudioStreamPlayer3D = $Player_sounds/death

@export var sens_horizontal = 0.05
@export var sens_vertical = 0.05

signal interaction_detected(node:Node3D)
signal interaction_detected_end(node:Node3D)
signal player_dead()

var SPEED = 5.0
const JUMP_VELOCITY = 4.5
var walking_speed = 5.0
var running_speed = 10.0
 
const ANIM_IDLE = "Idle"
const ANIM_WALK = "Walk"
const ANIM_RUN = "Run"
const ANIM_PUNCH = "Weapon"

const ANIM_JUMP_START = "Jump"
const ANIM_JUMP_IDLE = "Jump_Idle"
const ANIM_JUMP_END = "Jump_Land"

const ANIM_IDLE_WITH_GUN = "Idle_Gun"
const ANIM_RUN_WITH_GUN = "Run_Gun"

const ANIM_HELLO = "Wave"
const ANIM_YES = "Yes"
const ANIM_NO = "No"
const ANIM_DUCK = "Duck"

const ANIM_WALK_SHOOT = "Walk_Gun"
const ANIM_RUN_SHOOT = "Run_Gun_Shoot"

var is_running:bool = false
var is_locked:bool = false
var has_gun:bool = false
var is_in_air:bool = false
var is_shoot_gun:bool = false
var mouse_captured:bool = false
var death_animation_played = false
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
 
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
 
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sens_horizontal))
		visuals.rotate_y(deg_to_rad(event.relative.x * sens_horizontal))
		camera_mout.rotate_x(deg_to_rad(event.relative.y * sens_vertical))
 
func _physics_process(delta):
	if mouse_captured == false:
		var joypad_dir:Vector2 = Input.get_vector("player_look_left", "player_look_right", "player_look_up", "player_look_down")
		if joypad_dir.length() > 0:
			var look_dir = joypad_dir * delta
			rotate_y(-look_dir.x * 2.0)
			camera_mout.rotate_x(-look_dir.y)
			camera_mout.rotation.x = clamp(camera_mout.rotation.x - look_dir.y, -deg_to_rad(75), deg_to_rad(60))	
	if !animation_player.is_playing():
		is_locked = false
		is_shoot_gun = false
	# Add the gravity.
	if not is_on_floor():
		is_in_air = true
		velocity.y -= gravity * delta
	else:
		if is_in_air :
			is_in_air = false
			animation_player.play(ANIM_JUMP_END)
	if Input.is_action_just_pressed("equip_gun"):
		if has_gun: 
			has_gun = false
			gun.hide()
		else:
			has_gun = true
			gun.show()
	if Input.is_action_just_pressed("emote_hello"):
		if (animation_player.current_animation != ANIM_HELLO) :
				animation_player.play(ANIM_HELLO)
				is_locked = true
	if Input.is_action_just_pressed("emote_yes"):
		if (animation_player.current_animation != ANIM_YES) :
				animation_player.play(ANIM_YES)
				is_locked = true
	if Input.is_action_just_pressed("emote_no"):
		if (animation_player.current_animation != ANIM_NO) :
				animation_player.play(ANIM_NO)
				is_locked = true
	if Input.is_action_just_pressed("emote_duck"):
		if (animation_player.current_animation != ANIM_DUCK) :
				animation_player.play(ANIM_DUCK)
				is_locked = true
	if Input.is_action_pressed("player_run"):
		SPEED = running_speed
		is_running = true
	else:
		SPEED = walking_speed
		is_running = false
 
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation_player.play("Jump")
 
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if Input.is_action_just_pressed("player_gun"):
		if has_gun:
			sound_gun.pitch_scale = randf_range(0.5, 0.6)
			sound_gun.play()
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("enemy"):
					target.update_health(5)
						
			if direction:
				if (animation_player.current_animation != ANIM_RUN_SHOOT) :
					animation_player.play(ANIM_RUN_SHOOT)
					is_locked = true
					is_shoot_gun = true
			else :
				if (animation_player.current_animation != ANIM_RUN_SHOOT) :
					animation_player.play(ANIM_RUN_SHOOT)
					is_locked = true
					is_shoot_gun = true
		#else:
			#if (animation_player.current_animation != ANIM_PUNCH) :
				#animation_player.play(ANIM_PUNCH)
				#is_locked = true
				#is_shoot_gun = true
	if direction:
		if !is_locked:
			if is_in_air:
				if (animation_player.current_animation != ANIM_JUMP_IDLE) :
						animation_player.play(ANIM_JUMP_IDLE)
			else:
				if has_gun:
					if is_running:
						if (animation_player.current_animation != ANIM_RUN_WITH_GUN) :
							animation_player.play(ANIM_RUN_WITH_GUN)
							sound_running.pitch_scale = randf_range(0.5, 0.6)
							sound_running.play()
					else:
						if (animation_player.current_animation != ANIM_WALK_SHOOT) :
							animation_player.play(ANIM_WALK_SHOOT)
							sound_walking.pitch_scale = randf_range(0.5, 0.6)
							sound_walking.play()
				else :
					if is_running:
						if (animation_player.current_animation != ANIM_RUN) :
							animation_player.play(ANIM_RUN)
							sound_running.pitch_scale = randf_range(0.5, 0.6)
							sound_running.play()
					else:
						if (animation_player.current_animation != ANIM_WALK) :
							animation_player.play(ANIM_WALK)
							sound_walking.pitch_scale = randf_range(0.5, 0.6)
							sound_walking.play()
			visuals.look_at(position + direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		if !is_locked:
			if is_in_air:
				if (animation_player.current_animation != ANIM_JUMP_IDLE) :
						animation_player.play(ANIM_JUMP_IDLE)
			else:
				if has_gun:
					if (animation_player.current_animation != ANIM_IDLE_WITH_GUN) :
						animation_player.play(ANIM_IDLE_WITH_GUN)
				else:
					if (animation_player.current_animation != ANIM_IDLE) :
						animation_player.play(ANIM_IDLE)
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		_death_of_player()
	if !is_locked or is_shoot_gun:
		move_and_slide()

func _death_of_player():
	if(GameState.player_health <= 0) and not death_animation_played:
		sound_death.pitch_scale = randf_range(0.5, 0.6)
		sound_death.play()
		is_locked = true
		GameState.player_dead = true
		animation_player.play("Death")
		death_animation_played = true
		timer.start()
		

func _on_area_3d_body_entered(body):
	interaction_detected.emit(body)

func _on_area_3d_body_exited(body):
	interaction_detected_end.emit(body)
	
func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func _on_timer_timeout():
	GameState.box_collect = false
	GameState.health_kit = false
	GameState.card_key = false
	GameState.jar_collect = false
	GameState.player_dead = false
	death_animation_played = false
	GameState.player_health = 10
	player_dead.emit()
	for spawnpoint:SpawnPoint in GameState.current_level.find_children("", "SpawnPoint"):
		if (spawnpoint.key == "default"):
			GameState.player.position = spawnpoint.position
			GameState.player.rotation = spawnpoint.rotation 

