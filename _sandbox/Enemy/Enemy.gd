extends KinematicBody
class_name Enemy

export var chasing_player = true;
export var speed = 1;
export var jump = 40;

export var max_health := 12;
var current_health = int(max_health);

export var max_hits_consumption := 3;
var consumption = int(max_hits_consumption);
 
onready var player = get_tree().get_nodes_in_group("Player")[0];
onready var animationPlayer := $Animation;
onready var consumptionOrb := $ConsumptionOrb;
onready var deathTimer := $DeathTimer;
onready var mesh := $Mesh;
onready var playerDir;

var attacking;
var waitForNextAttack = false;
var is_dead = false;

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Attack").connect("body_entered", self, "_attachAttack")
	get_node("Attack").connect("body_exited", self, "_detachAttack")
	$DeathTimer.connect("timeout", self, "_remove");
	EventBus.connect("player_attacks", self, "_attacked");

func _process(delta):
	if(!is_instance_valid(self)):
		return;
		
	if player != null && is_instance_valid(player):
		var playerOrigin = player.transform.origin 
		playerDir = (playerOrigin - transform.origin).normalized()
		
		if is_dead:
			chasing_player = false;
		
		if chasing_player:
			look_at(playerOrigin, Vector3.UP);
			move_and_slide(playerDir * speed, Vector3.UP);
			attack();

func _attacked(target):
	if self.get_instance_id() != target.get_instance_id():
		return;
	
	if(!is_dead):
		animationPlayer.play("TakeDamage");
		animationPlayer.queue("RESET");
		move_and_slide(-playerDir * jump, Vector3.UP);
	
	if is_instance_valid(self):
		damage();

func _input(_event):
	if Input.is_key_pressed(KEY_ENTER):
		current_health = 0;

func damage(amount = 1):
	if !is_instance_valid(self):
		return;
	
	if current_health > 0:
		current_health -= amount;
	EventBus.emit_signal("enemy_hit");
	if current_health == 0:
		if(!is_dead):
			is_dead = true;
			mesh.visible = false;
			consumptionOrb.visible = true;
		consumption -= 1;
		deathTimer.start();
		if consumption <= 0:
			EventBus.emit_signal("enemy_consumed", 1);
			_remove();

func _remove():
	queue_free();
	
func _attachAttack(body):
	if body is Player:
		attacking = body;

func _detachAttack(body):
	if body is Player:
		attacking = null;

func attack():
	if is_instance_valid(attacking) && !waitForNextAttack:
		EventBus.emit_signal("player_hit"); # We rewrote this to make it simpler
		waitForNextAttack = true;
		
		yield(get_tree().create_timer(1.25), "timeout")
		if !is_instance_valid(self):
			return;
		waitForNextAttack = false;
