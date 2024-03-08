extends CharacterBody3D

@onready var animation = $Enemy2/AnimationPlayer
@onready var collision = $CollisionShape3D
@onready var raycast = $RayCast3D
@onready var timer = $Timer
@onready var enemy =  $"."

var ANIM_IDLE = ""

var health = 20
var speed:int = 3
var can_be_damage:bool = true
var is_in_air:bool = false
var is_locked:bool = false
var detection_radius:float = 20
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func update_health(damage):
	health = health-damage
	if health == 0:
		animation.play("Death")
		collision.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready():
	var number = RandomNumberGenerator.new().randi_range(1,4)
	if number == 1 :
		ANIM_IDLE = "Idle"
	else:
		if number == 2 :
			ANIM_IDLE = "No"
		else:
			if number == 3 :
				ANIM_IDLE = "Yes"
			else: 
				if number == 4 :
					ANIM_IDLE = "Duck"
	animation.play(ANIM_IDLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(GameState.player_health == 0):
			animation.play("Idle")
	if not is_on_floor():
		is_in_air = true
		velocity.y -= gravity * delta
	else:
		if is_in_air :
			is_in_air = false
			animation.play("Jump")
	if health > 0 and GameState.player_dead == false:
		if !animation.is_playing():
			is_locked = false
			
		var player_position = GameState.player.global_position
		var distance_to_player = global_transform.origin.distance_to(player_position)
		
		if (distance_to_player <= 2) :
			is_locked = true
			animation.play("Punch")
			if raycast.is_colliding():
				var target = raycast.get_collider()
				if target.is_in_group("player") and can_be_damage:
					GameState.player_health = GameState.player_health - 1
					can_be_damage = false
					timer.start()
					
		if (distance_to_player <= detection_radius):
			look_at(Vector3(GameState.player.global_position.x,global_position.y,GameState.player.global_position.z), Vector3.UP)
			var direction = global_position.direction_to(GameState.player.global_position)
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			#velocity = direction * speed
			if not is_locked:
				animation.play("Walk")
				move_and_slide()
		else:
			animation.play(ANIM_IDLE)
 


func _on_timer_timeout():
	can_be_damage = true
