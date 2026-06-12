extends Node2D

var _ANIMATION:AnimationPlayer = null
var _SPRITE:AnimatedSprite = null
var _AUDIO:AudioStreamPlayer = null
var _TIMER:Timer = null
var _EMITTER:Position2D = null
var _COLLIDER:Area2D = null
var _EXTENTS:CollisionShape2D = null
var _BTREE:Node = null

enum {VULNERABLE,IFRAME}

export var State:int = 0
export var new_state:int = 0
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
export var health:int = 100
export var health_regen:int = 2
export var energy_regen:int = 20
export var stun:float = 0
export var thrown:int = 0
export var thrown_multiplier:float = 0
export var angle_thrown:float = 0
export var damage:int = 0
export var proj_damage:int = 0
export var proj_speed:float = 0
export var STATE_INFO:Dictionary = {}
export var stats:String = ""

export var position_opp:Vector2
export var State_opp:int
export var vulnerability_opp:int
export var action_end_opp:bool
export var interrupt_opp:bool
export var velocity_opp:Vector2
export var projectiles_all:Array
export var STATE_INFO_opp:Dictionary = {}

var stun_opp:float = 0
var thrown_opp:int = 0
var thrown_multiplier_opp:float = 0
var angle_thrown_opp:float = 0
var damage_opp:int = 0

export var bounds_x:Vector2
export var bounds_y:Vector2
export var countdown:int = 0

var animation:String = "idle"
var distance_to_opp:float = 0
var angle_clamp:float
var facing:int = 1
var timeout:bool = false
var weapon = null
var jump_speedG:float = 0

var jump_multiplierG:float = 0
var jumping:bool = false
var gravity:float = 10
var areas:Array = []

var energy_timer:float = 0
var health_timer:float = 0
var jump_timeG:float = 0

const flip:bool = true
const forward:int = 1

var act_sequence:int = 0

func resetProperties():
	_EXTENTS.shape.set_extents(Vector2(18,36))
	_SPRITE.offset = Vector2(0,0)
	_COLLIDER.hit_frame = false
	_COLLIDER.iframe = false
	vulnerability = VULNERABLE

func interruptAct():
	if(vulnerability == VULNERABLE):
		interrupt = true
		return true
	else:
		return false

func setCollider():
	_COLLIDER.stun = stun
	_COLLIDER.angle_thrown = angle
	_COLLIDER.thrown = thrown
	_COLLIDER.damage = damage
	_COLLIDER.thrown_multiplier = thrown_multiplier

func move(var delta, var flipFace:bool = false):
	if(flipFace):
		face(velocity.x * -1)
	else:
		face(velocity.x)
	if(position == destination):
		return true
	var t:float = new_range(delta)
	position = position.linear_interpolate(destination,t)
	return false

func new_range(var delta):
	var end = position.distance_to(destination)
	var trav_speed = speed*delta
	var slope:float = 1/end
	var point:float = slope*(trav_speed)
	if(point>1):
		point = 1
	return point

func gravity(var delta):
	if(jump_speedG==0):
		return true
	var jump_velocityG:float = jump_speedG - gravity*jump_timeG
	if(_SPRITE.global_position.y>=position.y && jump_velocityG < 0):
		jump_speedG = 0
		jump_timeG = 0
		return true
	_SPRITE.position.y -= jump_velocityG * delta * jump_multiplierG
	jump_timeG += delta
	return false

func calcJump(var start_frame:int, var end_frame:int, var multiplier:float):
	var animation:Animation = _ANIMATION.get_animation(_ANIMATION.current_animation)
	var track:int = animation.find_track("AnimatedSprite:frame")
	var start_time:float = animation.track_get_key_time(track,start_frame)
	var end_time:float = animation.track_get_key_time(track,end_frame)
	var jump_duration:float = end_time-start_time
	jump_speedG = jump_duration*gravity/2
	jump_multiplierG = multiplier

func calcAnimDuration():
	duration = _ANIMATION.current_animation_length
	return duration

func calcDistanceToOpp():
	distance_to_opp = position.distance_to(position_opp)

func calcDestinationToOpp():
	destination = position_opp

func calcAngleToOpp():
	angle = position_opp.angle_to_point(position)
	angle = rad2deg(angle)

func calcDestination(var dest_distance:int, var dir_angle:float):
	destination = position + Vector2(dest_distance,0).rotated(deg2rad(dir_angle))
	clampDestination()
	
func clampDestination():
	destination.x = clamp(destination.x, bounds_x.x+18, bounds_x.y-18)
	destination.y = clamp(destination.y, bounds_y.x, bounds_y.y-36-10)

func atBounds():
	if(position.x == bounds_x.x+18 || position.x == bounds_x.y-18):
		return true
	if(position.y == bounds_y.x || position.y == bounds_y.y-36-10):
		return true
	return false

func calcVelocity(var trav_speed:int):
	velocity = (destination - position).normalized() * trav_speed
	speed = trav_speed

func face(var direction:float):
	if(direction>=0):
		scale.x = 1
		facing = 1
	else:
		scale.x = -1
		facing = -1
	return true

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

func timer(var startTime:float):
	if(startTime == 0):
		return true
	elif timeout:
		timeout = false
		return true 
	elif(_TIMER.time_left == 0):
		_TIMER.start(startTime)
		return false
	else:
		return false

func stopTimer():
	_TIMER.stop()

func changeState(var req_state:int):
	clampDestination()
	if(State != req_state || action_end):
		State = req_state
		stopTimer()
		resetProperties()
		var info = STATE_INFO.get(State)
		var change_values = info.keys()
		for key in change_values:
			match key:
				"energy":
					energy -= info.energy
				"iframe":
					setIFrame()
				_:
					set(key, info.get(key))
		setCollider()
		_ANIMATION.play(animation)
		return false
	return true

func setStateInfoOpp():
	_BTREE.STATE_INFO_opp = STATE_INFO_opp

func takeDamage():
	health -= damage_opp

func healthEnergyRegen(var delta):
	energy_timer += delta
	health_timer += delta
	if(energy_timer >= 0.1):
		energy_timer = 0
		energy += energy_regen/10
		if(energy>100):
			energy = 100
	if(health_timer >= 1):
		health_timer = 0
		if(health>0):
			health += health_regen
		if(health>100):
			health = 100

func setIFrame():
	_COLLIDER.iframe = true
	vulnerability = IFRAME

func setVictory():
	act_sequence += 1
	
func record(var win:bool, var time:float):
	var file = File.new()
	if(file.file_exists(str(name, ".txt"))):
		file.open(str(name, ".txt"), File.READ_WRITE)
	else:
		file.open(str(name, ".txt"), File.WRITE)
	file.seek_end()
	
	var dict:Dictionary = {}
	dict["win"] = win
	dict["time"] = time
	
	file.store_line(to_json(dict))
	file.close()

func generateStats():
	var file = File.new()
	file.open(str(name, ".txt"), File.READ)
	var file_length = file.get_len()
	var file_position = file.get_position()
	
	var char_name = name
	var total_matches:int = 0
	var total_wins:int = 0
	var win_rate:float = 0
	var total_win_time:float = 0
	var average_win_time:float = 0
	
	while(file_position != file_length):
		total_matches += 1
		var dict:Dictionary = {}
		dict = parse_json(file.get_line())
		if(dict["win"]):
			total_wins += 1
			total_win_time += dict["time"]
		file_position = file.get_position()
	
	if(total_matches != 0):
		win_rate = float(total_wins)/total_matches*100
		if(total_wins != 0):
			average_win_time = total_win_time/total_wins
		
	var win_rate_text = "%.02f" % win_rate
	
	var fight_time:float = average_win_time
	var time_min:int = fight_time/60
	var time_seconds:int = fight_time - time_min*60
	var time_ms:int = (fight_time - int(fight_time))*100
	var time_text = "%02d:%02d.%02d" % [time_min, time_seconds, time_ms]
		
	stats = str("[",char_name,"]\n\n",
		"Total Matches: ",total_matches,"\n",
		"Total Wins: ",total_wins,"\n",
		"Win Rate: ",win_rate_text,"%\n",
		"Average Win Time: ",time_text)
	file.close()
