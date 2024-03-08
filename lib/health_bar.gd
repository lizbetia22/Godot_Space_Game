extends ProgressBar

@onready var damagebar = $DamageBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	damagebar.value = GameState.player_health * 10 
