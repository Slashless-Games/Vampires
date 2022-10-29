extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var attacking;

export var freeze_slow := 0.07;
export var freeze_time := 0.4; 

func _ready():
	self.connect("body_entered", self, "_add_attacking");
	self.connect("body_exited", self, "_remove_attacking");
	EventBus.connect("enemy_hit", self, "_freeze");

func _add_attacking(body):
	attacking = body;
	get_parent().is_blocking = false;

func _remove_attacking(body):
	if(attacking && attacking == body):
		attacking = null;
		get_parent().is_blocking = false;

func _input(_event):
	if attacking && !is_instance_valid(attacking) || !attacking is Enemy:
		return;
	
	if is_instance_valid(attacking) && Input.is_action_just_pressed("ui_select") && attacking && attacking.is_attacking:
		get_parent().is_blocking = true;
		return;
	
	if Input.get_action_strength("ui_select") > 0:
		if attacking && attacking.has_method("_take_damage") && is_instance_valid(attacking):
			if !get_parent().is_blocking:
				attacking._take_damage(attacking)
	get_parent().is_blocking = false;
	
func _freeze():
	Engine.time_scale = freeze_slow;
	yield(get_tree().create_timer(freeze_time * freeze_slow), "timeout")
	Engine.time_scale = 1;
