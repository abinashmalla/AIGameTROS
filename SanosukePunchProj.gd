extends Area2D

export var bounds_x:Vector2
export var bounds_y:Vector2

export var hit_frame:bool = true

export var stun:float = 0
export var angle_thrown:float
export var thrown:int
export var thrown_multiplier:float
export var damage:int

export var velocity:Vector2
export var speed:float

func setBounds(var x:Vector2, var y:Vector2):
	bounds_x = x
	bounds_y = y

func clampY():
	if(position.y <= bounds_y.x):
		position.y = bounds_y.x
		var facing:int = 1
		if(velocity.x < 0):
			facing = -1
		velocity.x = facing*speed

func setCollider(var set_stun:float, var set_angle_thrown:float, var set_thrown:int, var set_thrown_multilpier:int, var set_damage:int):
	stun = set_stun
	angle_thrown = set_angle_thrown
	thrown = set_thrown
	thrown_multiplier = set_thrown_multilpier
	damage = set_damage

func _physics_process(delta):
	position += velocity * delta
	clampY()



func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
