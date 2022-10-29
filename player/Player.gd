extends KinematicBody
class_name Player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var max_health = 8;
var current_health = int(max_health);

export var speed = 5.0;
export var is_blocking = false;

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
	if !is_blocking:
		current_health -= 1;
		healthbar.value = current_health;
		if current_health == 0:
			queue_free()

func health_updated():
	pass;

