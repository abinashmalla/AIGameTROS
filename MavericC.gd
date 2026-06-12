extends "res://Character.gd"

const proj = preload("res://MavericProj.tscn")

enum {IDLE,DEFEND,FIREPROJECTILE,GETUP,JUMP,MOVE1,MOVE2,PUNCH,RECOVER,ROLL,RUN,
SLAM,STRONGPUNCH,STUN,THROWN,WALK,NULL_S}

var MAVERIC_STATE_INFO = {
	IDLE: {
		"animation": "idle",
		"skip": true
		},
	DEFEND: {
		"animation": "defend",
		"energy": 10,
		"iframe": true
	},
	FIREPROJECTILE: {
		"energy": 20,
		"stun": 1,
		"proj_speed": 800,
		"proj_damage": 10,
		"animation": "fireprojectile",
		"attack": true,
		"projectile": true
	},
	GETUP: {
		"duration": 0.5, 
		"animation": "getup",
		"recovery": true
		},
	JUMP: {
		"energy": 30,
		"distance": 100, 
		"animation": "jump",
#		"movement": true,
		"iframe": true
		},
	MOVE1: {
		"energy": 10,
		"stun": 0.5,
		"distance": 100,
		"damage": 10,
		"animation": "move1",
		"movement": true,
		"attack": true,
	},
	MOVE2: {
		"energy": 20,
		"stun": 0.5,
		"distance": 200,
		"damage": 15,
		"animation": "move2",
		"movement": true,
		"attack": true,
	},
	PUNCH: {
		"energy": 10,
		"stun": 0.8,
		"distance": 50,
		"damage": 10,
		"animation": "punch",
		"attack": true
		},
	RECOVER: {
		"distance": 100, 
		"animation": "recover",
		"recovery": true
		},
	ROLL: {
		"energy": 30,
		"speed": 170, 
		"animation": "roll",
#		"movement": true,
		"iframe": true
		},
	RUN: {
		"speed": 200, 
		"animation": "run",
		"skip": true,
		"movement": true
		},
	SLAM: {
		"energy": 20,
		"stun": 0,
		"thrown": 1000,
		"thrown_multiplier": 500,
		"start": 200,
		"distance": 300,
		"damage": 40,
		"animation": "slam",
		"attack": true,
	},
	STRONGPUNCH: {
		"energy": 30,
		"stun": 0,
		"thrown": 100,
		"thrown_multiplier": 100,
		"damage": 30,
		"distance": 50,
		"animation": "strongpunch",
		"attack": true,
	},
	STUN: {
		"animation": "stun"
		},
	THROWN: {
		"animation": "thrown",
		},
	WALK: {
		"speed": 100, 
		"animation": "walk",
		"skip": true,
		"movement": true
		}
}

func _ready():
	process_priority = 1
	
	_ANIMATION = $AnimationPlayer
	_SPRITE = $AnimatedSprite
	_TIMER = $Timer
	_EMITTER = $AnimatedSprite/Position2D
	_COLLIDER = $AnimatedSprite/Area2D
	_EXTENTS = $AnimatedSprite/Area2D/CollisionShape2D
	_BTREE = $BehaviorTree
	_AUDIO = $AudioStreamPlayer
	var _success = _TIMER.connect("timeout",self,"timeoutSignal")
	
	_BTREE.name = name
	
	STATE_INFO = MAVERIC_STATE_INFO
	_BTREE.STATE_INFO = STATE_INFO
	
	if(STATE_INFO_opp.empty()):
		_BTREE.STATE_INFO_opp = STATE_INFO
	
	generateStats()
	
	position = Vector2(300,300)
	duration = 0
	face(facing)
	idle()

func defend():
	if(!changeState(DEFEND)):
		calcAnimDuration()
		calcDestinationToOpp()
		calcVelocity(forward)
		face(velocity.x)
	return timer(duration)

func fireprojectile():
	if(!changeState(FIREPROJECTILE)):
		calcDestination(forward, angle)
		calcVelocity(forward)
		face(velocity.x)
		calcAnimDuration()
	return timer(duration)

func getup():
	changeState(GETUP)
	return timer(duration)

func idle():
	changeState(IDLE)
	return timer(duration)

func jump(var delta):
	if(!changeState(JUMP)):
		calcDestination(distance, angle)
		var jump_time = calcAnimDuration()
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
		calcAnimDuration()
	move(delta)
	return timer(duration)

func move1(var delta):
	if(!changeState(MOVE1)):
		calcDestination(distance,angle)
		var skip_time = calcAnimDuration()
		var skip_speed = (position.distance_to(destination))/skip_time
		calcVelocity(skip_speed)
		calcAnimDuration()
	move(delta)
	return timer(duration)

func move2(var delta):
	if(!changeState(MOVE2)):
		calcDestination(distance,angle)
		var skip_time = calcAnimDuration()
		var skip_speed = (position.distance_to(destination))/skip_time
		calcVelocity(skip_speed)
		calcAnimDuration()
	move(delta)
	return timer(duration)

func punch(var delta):
	if(!changeState(PUNCH)):
		calcDestination(distance,angle)
		var punch_time = calcAnimDuration()
		var punch_speed = (position.distance_to(destination))/punch_time
		calcVelocity(punch_speed)
		calcAnimDuration()
	move(delta)
	return timer(duration)

func recover(var delta):
	if(!changeState(RECOVER)):
		if(facing == 1):
			calcDestination(50,0)
		else:
			calcDestination(50,180)
		var recover_multiplier = 100
		calcJump(0,2,recover_multiplier)
		var jump_time = _ANIMATION.current_animation_length
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
		calcAnimDuration()
	move(delta,flip)
	return timer(duration)

func roll(var delta):
	if(!changeState(ROLL)):
		calcDestination(speed, angle)
		calcVelocity(speed)
	return move(delta)

func run(var delta):
	changeState(RUN)
	calcVelocity(speed)
	if(move(delta) || timer(duration)):
		return true
	return false

func slam(var delta):
	if(!changeState(SLAM)):
		calcDestination(distance, angle)
		var jump_time = calcAnimDuration()
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
		calcAnimDuration()
	move(delta)
	return timer(duration)

func strongpunch(var delta):
	if(!changeState(STRONGPUNCH)):
		calcDestination(distance,angle)
		var punch_time = calcAnimDuration()
		var punch_speed = (position.distance_to(destination))/punch_time
		calcVelocity(punch_speed)
		calcAnimDuration()
	move(delta)
	return timer(duration)

func stun():
	if(!changeState(STUN)):
		takeDamage()
	return timer(stun_opp)

func thrown(var delta):
	if(!changeState(THROWN)):
		takeDamage()
		calcDestination(thrown_opp, angle_thrown_opp)
		calcJump(0,4,thrown_multiplier_opp)
		var jump_time = calcAnimDuration()
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
		calcAnimDuration()
	move(delta)
	return timer(duration)

func walk(var delta):
	changeState(WALK)
	calcVelocity(speed)
	if(move(delta) || timer(duration)):
		return true
	return false

func victory():
	_ANIMATION.play("victory")

func loss():
	_ANIMATION.play("thrown")

func releaseProjectile():
	var projVelocity:Vector2 = Vector2(forward,0).rotated(deg2rad(angle))
	var projectile = proj.instance()
	get_parent().add_child(projectile)
	projectile.setBounds(bounds_x,bounds_y)
	angle_thrown = angle
	projectile.setCollider(stun,angle_thrown,thrown,thrown_multiplier,proj_damage)
	projectile.transform = _EMITTER.global_transform
	projectile.velocity = projVelocity.normalized() * proj_speed
	projectile.speed = proj_speed
	return true

func actState(var actState:int, var delta):
	match actState:
		DEFEND:
			return defend()
		FIREPROJECTILE:
			return fireprojectile()
		GETUP:
			return getup()
		IDLE:
			return idle()
		JUMP:
			return jump(delta)
		MOVE1:
			return move1(delta)
		MOVE2:
			return move2(delta)
		PUNCH:
			return punch(delta)
		RECOVER:
			return recover(delta)
		ROLL:
			return roll( delta)
		RUN:
			return run(delta)
		SLAM:
			return slam(delta)
		STRONGPUNCH:
			return strongpunch(delta)
		STUN:
			return stun()
		THROWN:
			return thrown(delta)
		WALK:
			return walk(delta)
		_:
			return idle()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	gravity(delta)
	match act_sequence:
		0:
			_ANIMATION.play("idle")
			if(timer(countdown)):
				act_sequence += 1
		1:
			_BTREE.updateBlackBoard()
			_BTREE.consultBTree()
			_BTREE.updateSelf()
			action_end = actState(new_state, delta)
			healthEnergyRegen(delta)
		2:
			if(actState(new_state, delta)):
				act_sequence += 1
		3:
			destination = Vector2(bounds_x.y/2, bounds_y.y * 3/4)
			duration = 10
			if(!actState(RUN,delta) && health > 0):
				return
			if(health > 0):
				victory()
			else:
				loss()
			act_sequence += 1
		4:
			return

func _on_Area2D_area_entered(area):
	if(!area.is_in_group("Maveric") && area.is_in_group("Projectile")):
		if(interruptAct()):
			stun_opp = area.stun
			angle_thrown_opp = area.angle_thrown
			thrown_opp = area.thrown
			damage_opp = area.damage
			thrown_multiplier_opp = area.thrown_multiplier
			return
	if(!area.is_in_group("Maveric") && !area.is_in_group("Projectile")):
		area.area_con.push_back(_COLLIDER)

func _on_Area2D_area_exited(area):
	if(!area.is_in_group("Maveric") && !area.is_in_group("Projectile")):
		area.area_con.erase(_COLLIDER)
		area.hit_areas.erase(_COLLIDER)

func _on_Area2D_hit(stun_opp_h, angle_thrown_opp_h, thrown_opp_h, thrown_multiplier_opp_h, damage_opp_h):
	if(interruptAct()):
		stun_opp = stun_opp_h
		angle_thrown_opp = angle_thrown_opp_h
		thrown_opp = thrown_opp_h
		damage_opp = damage_opp_h
		thrown_multiplier_opp = thrown_multiplier_opp_h
