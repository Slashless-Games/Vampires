extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var target;

export var freeze_slow := 0.07;
export var freeze_time := 0.4; 

func _ready():
	self.connect("body_entered", self, "_add_target");
	self.connect("body_exited", self, "_remove_target");
	EventBus.connect("enemy_hit", self, "_freeze");

func _add_target(body):
	target = body;

func _remove_target(body):
	if(target && target == body):
		target = null;

func _input(_event):
	print(get_parent().is_attacking);
	if target && !is_instance_valid(target):
		return;
	
	if(get_parent().is_attacking):
		return;
	
	if Input.get_action_strength("ui_select") > 0:
		if target is Enemy && is_instance_valid(target):
			EventBus.emit_signal("player_attacks", target);
	
func _freeze():
	Engine.time_scale = freeze_slow;
	yield(get_tree().create_timer(freeze_time * freeze_slow), "timeout")
	Engine.time_scale = 1;
