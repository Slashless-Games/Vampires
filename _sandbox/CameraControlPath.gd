extends PathFollow


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	EventBus.connect("distance_left", self, "_control_offset");
	pass # Replace with function body.

func _control_offset(player_distance, player_distance_away):
	#print(-(player_distance / player_distance_away));
	self.offset = -player_distance;

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
