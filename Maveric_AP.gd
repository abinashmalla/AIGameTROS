extends Node2D

const proj = preload("res://MavericProj.tscn")

var _ANIMATION:AnimationPlayer = null
var _TIMER:Timer = null
var _EMITTER:Position2D = null
var _COLLIDER:Area2D = null

enum {IDLE,DEFEND,FIREPROJECTILE,GETUP,JUMP,MOVE1,MOVE2,PUNCH,RECOVER,ROLL,RUN,
SLAM,STRONGPUNCH,STUN,THROWN,WALK,NULL_S}

enum {VULNERABLE,IFRAME}

export var State:int = NULL_S
export var new_state:int = IDLE
export var vulnerability:int = VULNERABLE
export var action_end:bool = false
export var interrupt:bool = false
export var destination:Vector2
export var velocity:Vector2
export var duration:float = 0
export var angle:float = 0
export var distance:int = 1

export var walk_speed:int = 100
export var run_speed:int = 200
export var jump_distance:int = 100
export var roll_speed:int = 170
export var skip_distance:int = 100
export var slam_distance:int = 300
export var punch_distance:int = 100
export var recover_dist:int = 100
export var proj_speed:int = 800

export var position_opp:Vector2
export var State_opp:int
export var vulnerability_opp:int
export var action_end_opp:bool
export var interrupt_opp:bool
export var velocity_opp:Vector2

var facing:int = 1
var fired:bool = false
var timeout:bool = false

const flip:bool = true
const forward:int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	process_priority = 1
	
	_ANIMATION = $AnimationPlayer
	_TIMER = $Timer
	_EMITTER = $AnimatedSprite/Position2D
	_COLLIDER = $AnimatedSprite/Area2D
	
	var _success = _TIMER.connect("timeout",self,"timeoutSignal")
	
	position = Vector2(100,400)
	
	idle()

func defend():
	if(!changeState(DEFEND)):
		_ANIMATION.play("DEFEND")
		duration = _ANIMATION.current_animation_length
	return timer(duration)

func fireprojectile():
	if(!changeState(FIREPROJECTILE)):
		fired = false
		_ANIMATION.play("fireprojectile")
		calcDestination(forward, angle)
		calcVelocity(forward)
		face(velocity.x)
	if(timer(_ANIMATION.current_animation_length) && fired):
		fired = false
		return true
	return false

func getup():
	if(!changeState(GETUP)):
		_ANIMATION.play("getup")
	return timer(duration)

func idle():
	if(!changeState(IDLE)):
		_ANIMATION.play("idle")
	return timer(duration)

func jump(var delta):
	if(!changeState(JUMP)):
		_ANIMATION.play("jump")
		calcDestination(jump_distance, angle)
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
	return move(delta)

func move1(var delta):
	if(!changeState(MOVE1)):
		_ANIMATION.play("move1")
		calcDestination(skip_distance,angle)
		var skip_time = _ANIMATION.current_animation_length
		var skip_speed = (position.distance_to(destination))/skip_time
		calcVelocity(skip_speed)
	return move(delta)

func move2(var delta):
	if(!changeState(MOVE2)):
		_ANIMATION.play("move2")
		calcDestination(skip_distance,angle)
		var skip_time = _ANIMATION.current_animation_length
		var skip_speed = (position.distance_to(destination))/skip_time
		calcVelocity(skip_speed)
	return move(delta)

func punch(var delta):
	if(!changeState(PUNCH)):
		_ANIMATION.play("punch")
		calcDestination(punch_distance,angle)
		var punch_time = _ANIMATION.current_animation_length
		var punch_speed = (position.distance_to(destination))/punch_time
		calcVelocity(punch_speed)
	return move(delta)

func recover(var delta):
	if(!changeState(RECOVER)):
		_ANIMATION.play("recover")
		destination.x += facing*recover_dist
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
	return move(delta, flip)

func roll(var delta):
	if(!changeState(ROLL)):
		_ANIMATION.play("roll")
		calcDestination(roll_speed, angle)
		calcVelocity(roll_speed)
	return move(delta)

func run(var delta):
	if(!changeState(RUN)):
		_ANIMATION.play("run")
		calcVelocity(run_speed)
	return move(delta)

func slam(var delta):
	if(!changeState(SLAM)):
		_ANIMATION.play("slam")
		calcDestination(slam_distance, angle)
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
	return move(delta)

func strongpunch(var delta):
	if(!changeState(STRONGPUNCH)):
		_ANIMATION.play("strongpunch")
		calcDestination(punch_distance,angle)
		var punch_time = _ANIMATION.current_animation_length
		var punch_speed = (position.distance_to(destination))/punch_time
		calcVelocity(punch_speed)
	return move(delta)

func stun():
	if(!changeState(STUN)):
		_ANIMATION.play("stun")
	return (timer(duration))

func thrown(var delta):
	if(!changeState(THROWN)):
		_ANIMATION.play("thrown")
		calcDestination(distance, angle)
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
	return move(delta)

func walk(var delta):
	if(!changeState(WALK)):
		_ANIMATION.play("walk")
		calcVelocity(walk_speed)
	return move(delta)

func releaseProjectile():
	var projVelocity:Vector2 = Vector2(forward,0).rotated(deg2rad(angle))
	var projectile = proj.instance()
	get_parent().add_child(projectile)
	projectile.transform = _EMITTER.global_transform
	projectile.velocity = projVelocity.normalized() * proj_speed
	fired = true
	return true

func interruptAct():
	if(vulnerability == VULNERABLE):
		interrupt = true
		return true
	else:
		return false

func setCollider(var set_duration:float, var set_angle:float, var set_distance:int):
	_COLLIDER.duration = set_duration
	_COLLIDER.angle = set_angle
	_COLLIDER.distance = set_distance

func move(var delta, var flipFace:bool = false):
	if(flipFace):
		face(velocity.x * -1)
	else:
		face(velocity.x)
	var prev:float = position.distance_squared_to(destination)
	position += velocity * delta
	var new:float = position.distance_squared_to(destination)
	if(!closing(prev, new)):
		position = destination
		return true
	return false

func calcDestination(var dest_distance:int, var dir_angle:float):
	destination = position + Vector2(dest_distance,0).rotated(deg2rad(dir_angle))
	
func calcVelocity(var speed:int):
	velocity = (destination - position).normalized() * speed

func face(var direction:float):
	if(direction>=0):
		scale.x = 1
		facing = 1
	else:
		scale.x = -1
		facing = -1
	return true

func closing(var prev:float, var new:float):
	if(new < prev):
		return true
	else:
		return false

func clampAngle(var in_angle:float, var clampAngle:float):
	if(in_angle > 90):
		in_angle = clamp(in_angle, 180 - abs(clampAngle), 180)
	elif(in_angle < -90):
		in_angle = clamp(in_angle,-180, -180 + abs(clampAngle))
	else:
		in_angle = clamp(in_angle,-abs(clampAngle),abs(clampAngle))
	return in_angle

func timeoutSignal():
	timeout = true

func timer(var startTime:float, var timer_interrupt:bool = false):
	if(startTime == 0):
		return true
	elif timeout:
		timeout = false
		return true 
	elif(timer_interrupt):
		_TIMER.stop()
		return true
	elif(_TIMER.time_left == 0):
		_TIMER.start(startTime)
		return false
	else:
		return false

func changeState(var req_state:int):
	if(State != req_state):
		State = req_state
		return false
	return true

func actState(var actState:int, var delta):
	match actState:
		DEFEND:
			return defend()
		FIREPROJECTILE:
			angle = 110
			return fireprojectile()
		GETUP:
			duration = 1
			return getup()
		IDLE:
			return idle()
		JUMP:
			angle = 0
			return jump(delta)
		MOVE1:
			angle = 30
			return move1(delta)
		MOVE2:
			angle = -30
			return move2(delta)
		PUNCH:
			angle = 0
			return punch(delta)
		RECOVER:
			return recover(delta)
		ROLL:
			angle = 0
			return roll( delta)
		RUN:
			return run(delta)
		SLAM:
			angle = 0
			return slam(delta)
		STRONGPUNCH:
			angle = -180
			return strongpunch(delta)
		STUN:
			duration = 2
			return stun()
		THROWN:
			angle = 0
			distance = 100
			return thrown(delta)
		WALK:
			return walk(delta)
		_:
			idle()
			return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	action_end = actState(new_state, delta)

func _on_Area2D_area_entered(area):
	if(!area.is_in_group("Maveric")):
		if(interruptAct()):
			duration = area.duration
			angle = area.angle
			distance = area.distance
