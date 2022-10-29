extends KinematicBody
class_name Player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var max_health = 8;
var current_health = int(max_health);

export var speed = 5.0;
var is_attacking = false;

var horizontal = 0;
var vertical = 0;
var currSpeed = 0;

onready var collider = $MainCollision;
onready var healthbar = $HealthBar;

# Called when the node enters the scene tree for the first time.
func _ready():
	healthbar.rect_size = Vector2((max_health / 2) * 100, 20);
	healthbar.min_value = 0;
	healthbar.max_value = max_health;
	EventBus.connect("player_hit", self, "take_damage");
	EventBus.connect("player_attacks", self, "set_is_attacking");
	EventBus.connect("enemy_consumed", self, "add_health");
	
func _input(_event):
	horizontal = Input.get_action_strength("left") - Input.get_action_strength("right");
	vertical = Input.get_action_strength("forward") - Input.get_action_strength("backward");
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var vel = Vector3(horizontal,0, -vertical)
	
	if vel.length() > 0:
		look_at(transform.origin + vel, Vector3.UP)
		currSpeed += 0.5;
	else:
		currSpeed -= 0.005;
	currSpeed = clamp(currSpeed, 0, speed);
	
	if Input.is_action_just_pressed("dodge"):
		collider.disabled = true;
		currSpeed = 20 * currSpeed;
	elif collider.disabled:
		collider.disabled = false;
	
	move_and_slide(vel * currSpeed, Vector3.UP);

func take_damage():
	if is_attacking:
		return
	current_health -= 1;
	healthbar.value = current_health;
	
	if current_health <= 0:
		queue_free()
	
func set_is_attacking(target):
	is_attacking = true;
	yield(get_tree().create_timer(0.2), "timeout")
	is_attacking = false;

func add_health(amount = 1):
	if (current_health + amount) < max_health:
		current_health += amount;
		healthbar.value = current_health;
		yield(get_tree().create_timer(0.2), "timeout")
