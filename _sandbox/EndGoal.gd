extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = get_tree().get_nodes_in_group("Player")[0];

onready var player_distance_away;
var previous_distance = 0;

func _ready():
	player_distance_away = (player.transform.origin - transform.origin).length();
	previous_distance = player_distance_away;
	pass;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_distance = (player.transform.origin - transform.origin).length();
	if(previous_distance != player_distance):
		print(player_distance);
		EventBus.emit_signal("distance_left", player_distance, player_distance_away);
		previous_distance = player_distance;
	pass
