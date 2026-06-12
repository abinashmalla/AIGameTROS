extends Node2D

const punchProj = preload("res://SanosukePunchProj.tscn")
const weaponProj = preload("res://SanosukeWeaponProj.tscn")

enum {GETUP,IDLE,JUMP,RECOVER,ROLL,RUN,SANOSUKEPOWA,SANOSUKEPUNCH,
SANOSUKEWEAPONTHROW,STUN,THROWN,UPPERCUT,WALK}

const interruptAct:bool = true

var State:int = IDLE

var facing:int = 1
var walk_speed:int = 100
var run_speed:int = 200
var jump_height:int = 80
var flying:bool = false

var velocity:Vector2 = Vector2(100,100)
var flyPos:Vector2 = Vector2(-1,-1)
var prevPos:Vector2 = Vector2(0,0)
var nextDisplace:Vector2 = Vector2(0,0)

var actSequence:int = 0
var stateSequence:int = 1
var timeout:bool = false
var fired:bool = false

var _SPRITE:AnimatedSprite = null
var _COL:CollisionShape2D = null
var _EMITTER:Position2D = null
var _TIMER:Timer = null

var colSize:Vector2 = Vector2(100,100)
var colPos:Vector2 = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	_SPRITE = $AnimatedSprite
	_COL = $CollisionShape2D
	_EMITTER = $Position2D
	_TIMER = $Timer
	
	_TIMER.connect("timeout",self,"timeoutSignal")
	
	colSize = _COL.shape.extents
	colPos = _COL.position
	
	face(facing)
	position = Vector2(100,600/2)
	velocity = Vector2(0,0)

func timeoutSignal():
	timeout = true

func calcTime(var frames:int, var fps:float):
	return float(frames) * 1/fps

func autoTimeSet(var animation:String):
	var frames:int = _SPRITE.frames.get_frame_count(animation)
	var fps:float = _SPRITE.frames.get_animation_speed(animation)
	return calcTime(frames,fps)

func timer(var startTime:float, var interrupt:bool = false):
	if timeout:
		timeout = false
		return true 
	elif(interrupt):
		_TIMER.stop()
		return true
	elif(_TIMER.time_left == 0):
		_TIMER.start(startTime)
		return false
	else:
		return false
		
func closing(var prev:float, var new:float):
	if(new < prev):
		return true
	else:
		return false

func face(var direction:float):
	if(direction>=0):
		scale.x = 1
		facing = 1
	else:
		scale.x = -1
		facing = -1
	return true

func move(var displacement:Vector2, var speed:float, var delta):
	var location:Vector2 = position + displacement
	velocity = displacement.normalized()
	var prev:float = position.distance_squared_to(location)
	position += velocity * speed * delta
	var new:float = position.distance_squared_to(location)
	if(!closing(prev, new)):
		position = location
		return true
	return false

func fly(var displacement:Vector2, var time:float, var delta, var height:float=0, var interrupt:bool=false): 
	if(!flying):
		prevPos = position
		flying = true
		if(time==0):
			time=1
		timer(time)
	var startPos:Vector2 = prevPos
	var endPos:Vector2 = prevPos+displacement
	var midPos:Vector2 = Vector2((startPos.x + endPos.x)/2, (startPos.y + endPos.y)/2-height)
	
	velocity.x = (endPos.x - startPos.x)/time
	if(height>0):
		if(_TIMER.time_left > time/2):
			velocity.y = (midPos.y - startPos.y)/(time/2)
		else:
			velocity.y = (endPos.y - midPos.y)/(time/2)
	else:
		velocity.y = (endPos.y - startPos.y)/time
		
	position += velocity * delta
	flyPos = position
	if(timer(time)):
		position = endPos
		flying = false
		return true
	elif(interrupt):
		nextDisplace = endPos - position
		flying = false
		return timer(0,interrupt)
	else:
		return false

func walk(var location:Vector2, var delta):
	if(State != WALK):
		State = WALK
		_SPRITE.animation = "walk"
		face(location.x-position.x)
	var displacement:Vector2 = location - position
	return move(displacement, walk_speed, delta)

func run(var location:Vector2, var delta):
	if(State != RUN):
		State = RUN
		_SPRITE.animation = "run"
		face(location.x-position.x)
	var displacement:Vector2 = location - position
	return move(displacement, run_speed, delta)

func jump(var displacement:Vector2, var delta):
	match(actSequence):
		0:
			if(getup(0.1)):
				actSequence += 1
		1:
			if(State != JUMP):
				State = JUMP
				_SPRITE.animation = "jump"
				face(displacement.x)
			if(abs(displacement.x) > 100):
				displacement.x = facing * 100
			elif(abs(displacement.y) > jump_height):
				if(displacement.y > 0):
					displacement.y = jump_height
				else:
					displacement.y = -jump_height
			var height:float = jump_height - abs(displacement.y)
			if(fly(displacement, autoTimeSet("jump"), delta, height)):
				actSequence += 1
		2:
			if(getup(0.1)):
				actSequence = 0
				return true
	return false

func getup(var time:float = 0.5):
	if(State != GETUP):
		State = GETUP
		_SPRITE.animation = "getup"
	return timer(time)

func thrown(var delta,var interrupt:bool = false):
	if(State != THROWN):
		State = THROWN
		_SPRITE.animation = "thrown"
		face(-facing)
	return fly(Vector2(facing*100,0), autoTimeSet(_SPRITE.animation), delta, 50, interrupt)

func recover(var delta):
	if(State != RECOVER):
		State = RECOVER
		_SPRITE.animation = "recover"
		face(-facing)
	return fly(nextDisplace + Vector2(-facing*20,0), autoTimeSet(_SPRITE.animation), delta)

func roll(var delta):
	if(State != ROLL):
		State = ROLL
		_SPRITE.animation = "roll"
	if(timer(1)):
		return true
	else:
		move(Vector2(facing*10,0), run_speed, delta)
		return false

func uppercut(var delta):
	if(State != UPPERCUT):
		State = UPPERCUT
		_SPRITE.animation = "uppercut"
	return fly(Vector2(facing*100,0), autoTimeSet(_SPRITE.animation), delta, 80)

func stun():
	if(State != STUN):
		State = STUN
		_SPRITE.animation = "stun"
	return(timer(1))

func sanosukepowa():
	if(State != SANOSUKEPOWA):
		State = SANOSUKEPOWA
		_SPRITE.animation = "sanosukepowa"
		_SPRITE.offset.y = -160
		_COL.shape.extents = Vector2(94,80)
		_COL.position.y = -43
	if(timer(autoTimeSet(_SPRITE.animation))):
		_SPRITE.offset.y = 0
		_COL.shape.extents = colSize
		_COL.position.y = colPos.y
		_SPRITE.animation = "idle"
		return true
	else:
		return false

func sanosukeweaponthrow(var location:Vector2):
	if(State != SANOSUKEWEAPONTHROW):
		State = SANOSUKEWEAPONTHROW
		_SPRITE.animation = "sanosukeweaponthrow"
		_EMITTER.position = Vector2(0,-47)
	if(timer(autoTimeSet(_SPRITE.animation))):
		_EMITTER.position = Vector2(0,0)
		fired = false
		return true
	elif(_SPRITE.frame == 0 && !fired):
		var projectile = weaponProj.instance()
		get_parent().add_child(projectile)
		projectile.transform = _EMITTER.global_transform
		projectile.velocity = location.normalized()
		fired = true
	return false

func sanosukepunch(var angle:float):
	if(State != SANOSUKEPUNCH):
		State = SANOSUKEPUNCH
		_SPRITE.animation = "sanosukepunch"
		_EMITTER.position = Vector2(14,0)
	if (timer(autoTimeSet(_SPRITE.animation))):
		_EMITTER.position = Vector2(0,0)
		fired = false
		return true
	elif(_SPRITE.frame == 3 && !fired):
		angle = clamp(angle,-30,30)
		var projVelocity:Vector2 = Vector2(facing,0).rotated(deg2rad(facing*angle))
		var projectile = punchProj.instance()
		get_parent().add_child(projectile)
		projectile.transform = _EMITTER.global_transform
		projectile.velocity = projVelocity.normalized()
		fired = true
	return false

func sequence(var delta):
	match stateSequence:
		1:
			if(sanosukepunch(40)):
				stateSequence += 1
#			if(run(Vector2(400,300),delta)):
#				stateSequence += 1
		2:
			if(jump(Vector2(100,0), delta)):
				stateSequence += 1
		3:
			if(thrown(delta)):
				stateSequence += 1
			elif(_TIMER.time_left<calcTime(5,8)/2):
				thrown(delta,interruptAct)
				stateSequence += 1
		4:
			if(recover(delta)):
				stateSequence += 1
		5:
			if(roll(delta)):
				stateSequence += 1
		6:
			if(getup()):
				stateSequence += 1
		7:
			if(uppercut(delta)):
				stateSequence += 1
		8:
			if(stun()):
				stateSequence += 1
		9:
			if(sanosukepowa()):
				stateSequence += 1
		10:
			if(sanosukeweaponthrow(Vector2(1,1))):
				stateSequence += 1
		_:
			State = IDLE
			_SPRITE.animation = "idle"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sequence(delta)
