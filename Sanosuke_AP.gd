extends Node2D

const punchProj = preload("res://SanosukePunchProj.tscn")
const weaponProj = preload("res://SanosukeWeaponProj.tscn")

var _ANIMATION:AnimationPlayer = null
var _TIMER:Timer = null
var _EMITTER:Position2D = null
var _COLLIDER:Area2D = null
var _BTREE:Node = null

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
export var speed:int = 0
export var energy:int = 100

enum {IDLE,GETUP,JUMP,PUNCH,RECOVER,ROLL,RUN,SANOSUKEPOWA,SANOSUKEPUNCH,
SANOSUKEWEAPONTHROW,STUN,THROWN,UPPERCUT,WALK,NULL_S}

var STATE_INFO = {
	GETUP: {"duration": 0.5, "animation": "getup"},
	IDLE: {"duration": 0, "animation": "idle"},
	JUMP: {"distance": 100, "animation": "jump"},
	PUNCH: {"energy": 10,"distance": 0, "duration": 0.5, "animation": "punch"},
	RECOVER: {"distance": 100, "animation": "recover"},
	ROLL: {"speed": 170, "animation": "roll"},
	RUN: {"speed": 200, "animation": "run"},
	SANOSUKEPOWA: {"energy": 80,"distance": 100, "thrown": 700, "animation": "sanosukepowa"},
	SANOSUKEPUNCH: {"energy": 30,"thrown": 1000, "speed": 400, "animation": "sanosukepunch"},
	SANOSUKEWEAPONTHROW: {"thrown": 100, "speed": 1000, "animation": "sanosukeweaponthrow"},
	STUN: {"animation": "stun"},
	THROWN: {"animation": "thrown"},
	UPPERCUT: {"energy": 20,"distance": 100, "thrown": 700, "animation": "uppercut"},
	WALK: {"speed": 100, "animation": "walk"}
}

export var position_opp:Vector2
export var State_opp:int
export var vulnerability_opp:int
export var action_end_opp:bool
export var interrupt_opp:bool
export var velocity_opp:Vector2

var animation:String = "idle"
var facing:int = 1
var timeout:bool = false
var weapon = null

const flip:bool = true
const forward:int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	process_priority = 1
	
	_ANIMATION = $AnimationPlayer
	_TIMER = $Timer
	_EMITTER = $AnimatedSprite/Position2D
	_COLLIDER = $AnimatedSprite/Area2D
	_BTREE = $BehaviorTree
	
	var _success = _TIMER.connect("timeout",self,"timeoutSignal")
	
	position = Vector2(300,300)
	face(facing)
	
	idle()

func getup():
	changeState(GETUP)
	return timer(duration)

func idle():
	changeState(IDLE)
	return timer(duration)

func jump(var delta):
	if(!changeState(JUMP)):
		calcDestination(distance, angle)
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
	return move(delta)

func punch():
	if(!changeState(PUNCH)):
		calcDestination(forward, angle)
		calcVelocity(forward)
		face(velocity.x)
		duration = _ANIMATION.current_animation_length
	return timer(duration)

func recover(var delta):
	if(!changeState(RECOVER)):
		destination.x += facing*distance
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
	return move(delta, flip)

func roll(var delta):
	if(!changeState(ROLL)):
		calcDestination(speed, angle)
		calcVelocity(speed)
	return move(delta)

func run(var delta):
	if(!changeState(RUN)):
		calcVelocity(speed)
	return move(delta)

func sanosukepowa():
	if(!changeState(SANOSUKEPOWA)):
		duration = _ANIMATION.current_animation_length
	return timer(duration)

func sanosukepunch():
	if(!changeState(SANOSUKEPUNCH)):
		calcDestination(forward, angle)
		calcVelocity(forward)
		face(velocity.x)
		duration = _ANIMATION.current_animation_length
	return timer(duration)

func sanosukeweaponthrow():
	if(!changeState(SANOSUKEWEAPONTHROW)):
		calcDestination(forward, angle)
		calcVelocity(forward)
		face(velocity.x)
		duration = _ANIMATION.current_animation_length
	return timer(duration)

func stun():
	changeState(STUN)
	return timer(duration)

func thrown(var delta):
	if(!changeState(THROWN)):
		calcDestination(distance, angle)
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
	return move(delta)

func uppercut(var delta):
	if(!changeState(UPPERCUT)):
		calcDestination(distance, angle)
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
	return move(delta)

func walk(var delta):
	if(!changeState(WALK)):
		calcVelocity(speed)
	return move(delta)

func punchFire():
	angle = clampAngle(angle, 30)
	var projVelocity:Vector2 = Vector2(forward,0).rotated(deg2rad(angle))
	var projectile = punchProj.instance()
	get_parent().add_child(projectile)
	projectile.transform = _EMITTER.global_transform
	projectile.velocity = projVelocity.normalized() * speed
	return true

func spawnWeapon():
	weapon = weaponProj.instance()
	get_parent().add_child(weapon)
	weapon.transform = _EMITTER.global_transform
	weapon.velocity = Vector2(0,0)
	return true

func throwWeapon():
	weapon.velocity = Vector2(forward,0).rotated(deg2rad(angle)) * speed
	weapon = null
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
	
func calcVelocity(var trav_speed:int):
	velocity = (destination - position).normalized() * trav_speed

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
	if(State != req_state || action_end):
		State = req_state
		var info = STATE_INFO.get(State)
		var change_values = info.keys()
		for key in change_values:
			match key:
				"energy":
					energy -= info.energy
				_:
					set(key, info.get(key))
		_ANIMATION.play(animation)
		return false
	return true

func actState(var actState:int, var delta):
	match actState:
		GETUP:
			return getup()
		IDLE:
			return idle()
		JUMP:
			return jump(delta)
		PUNCH:
			return punch()
		RECOVER:
			return recover(delta)
		ROLL:
			return roll( delta)
		RUN:
			return run(delta)
		SANOSUKEPOWA:
			return sanosukepowa()
		SANOSUKEPUNCH:
			return sanosukepunch()
		SANOSUKEWEAPONTHROW:
			return sanosukeweaponthrow()
		STUN:
			return stun()
		THROWN:
			return thrown(delta)
		UPPERCUT:
			return uppercut(delta)
		WALK:
			return walk(delta)
		_:
			return idle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
#	_BTREE.updateBlackBoard()
#	_BTREE.consultBTree()
#	_BTREE.updateSelf()
	action_end = actState(new_state, delta)
	pass

func _on_Area2D_area_entered(area):
	if(!area.is_in_group("Sanosuke")):
		if(interruptAct()):
			duration = area.duration
			angle = area.angle
			distance = area.distance
