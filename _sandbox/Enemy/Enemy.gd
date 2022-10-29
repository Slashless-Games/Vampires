extends KinematicBody
class_name Enemy


export var speed = 1;
export var jump = 40;

export var max_health := 4;
export var is_attacking = false;
var current_health = int(max_health);


onready var player = get_tree().get_nodes_in_group("Player")[0];
onready var animationPlayer := $Animation;
onready var playerDir;

var attacking;
var waitForNextAttack = false;



# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Attack").connect("body_entered", self, "_attachAttack")
	get_node("Attack").connect("body_exited", self, "_detachAttack")
	pass # Replace with function body.

func _process(delta):
	if player != null && is_instance_valid(player):
		var playerOrigin = player.transform.origin 
		playerDir = (playerOrigin - transform.origin).normalized()
		look_at(playerOrigin, Vector3.UP);
		move_and_slide(playerDir * speed, Vector3.UP);
		if(is_instance_valid(self)):
			attack();

func _take_damage(attacked):
	if self.name == attacked.name:
		animationPlayer.play("TakeDamage");
		animationPlayer.queue("RESET");
		move_and_slide(-playerDir * jump, Vector3.UP);
		current_health -= 1; # TODO: Could also be affected by "attached weapon"
		EventBus.emit_signal("enemy_hit");
		if(current_health == 0):
			queue_free() #TODO: Play death animation first...
		

func _attachAttack(body):
	if body is Player:
		attacking = body;

func _detachAttack(body):
	if body is Player:
		attacking = null;

func attack():
	if is_instance_valid(attacking) && attacking && attacking.has_method("take_damage") && !waitForNextAttack:
		is_attacking = true;
		if !attacking.is_blocking:
			attacking.take_damage();
		waitForNextAttack = true;
		yield(get_tree().create_timer(1.25), "timeout")
		waitForNextAttack = false;
		is_attacking = false;
