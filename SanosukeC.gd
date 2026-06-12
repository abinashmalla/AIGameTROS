extends "res://Character.gd"

const punchProj = preload("res://SanosukePunchProj.tscn")
const weaponProj = preload("res://SanosukeWeaponProj.tscn")

enum {IDLE,GETUP,JUMP,PUNCH,RECOVER,ROLL,RUN,SANOSUKEPOWA,SANOSUKEPUNCH,
SANOSUKEWEAPONTHROW,STUN,THROWN,UPPERCUT,WALK,NULL_S}

var SANOSUKE_STATE_INFO = {
	IDLE: {
		"animation": "idle",
		"skip": true
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
	PUNCH: {
		"energy": 10,
		"stun": 1.5,
		"distance": 18,
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
	SANOSUKEPOWA: {
		"energy": 70,
		"stun": 0,
		"thrown": 700,
		"thrown_multiplier": 400,
		"damage": 40, 
		"distance": 100,
		"animation": "sanosukepowa",
		"attack": true,
		"iframe": true,
		"follow": SANOSUKEWEAPONTHROW
		},
	SANOSUKEPUNCH: {
		"energy": 30,
		"stun": 0,
		"thrown": 1000, 
		"thrown_multiplier": 300,
		"proj_speed": 400,
		"proj_damage": 30,
		"angle_clamp": 30,
		"animation": "sanosukepunch",
		"attack": true,
		"projectile": true
		},
	SANOSUKEWEAPONTHROW: {
		"stun": 0,
		"thrown": 100, 
		"thrown_multiplier": 100,
		"proj_speed": 1000,
		"proj_damage": 20, 
		"animation": "sanosukeweaponthrow",
		"projectile": true,
		"followed": true
		},
	STUN: {
		"animation": "stun"
		},
	THROWN: {
		"animation": "thrown",
		},
	UPPERCUT: {
		"energy": 20,
		"stun": 0,
		"distance": 100, 
		"thrown": 50, 
		"thrown_multiplier": 100,
		"damage": 20,
		"animation": "uppercut",
		"attack": true
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
	
	STATE_INFO = SANOSUKE_STATE_INFO
	_BTREE.STATE_INFO = STATE_INFO
	
	if(STATE_INFO_opp.empty()):
		_BTREE.STATE_INFO_opp = STATE_INFO
	
	generateStats()
	
	position = Vector2(300,400)
	duration = 0
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
		var jump_time = calcAnimDuration()
		var jump_speed = (position.distance_to(destination))/jump_time
		calcVelocity(jump_speed)
		calcAnimDuration()
	move(delta)
	return timer(duration)

func punch():
	if(!changeState(PUNCH)):
		calcDestination(forward, angle)
		calcVelocity(forward)
		face(velocity.x)
		calcAnimDuration()
	return timer(duration)

func recover(var delta):
	if(!changeState(RECOVER)):
		if(facing == 1):
			calcDestination(50,0)
		else:
			calcDestination(50,180)
		var recover_multiplier = 100
		calcJump(0,2,recover_multiplier)
		var jump_time = calcAnimDuration()
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

func sanosukepowa():
	if(!changeState(SANOSUKEPOWA)):
		calcAnimDuration()
	if(timer(duration)):
		return true
	return false

func sanosukepunch():
	if(!changeState(SANOSUKEPUNCH)):
		calcDestination(forward, angle)
		calcVelocity(forward)
		face(velocity.x)
		calcAnimDuration()
	return timer(duration)

func sanosukeweaponthrow():
	if(!changeState(SANOSUKEWEAPONTHROW)):
		calcDestinationToOpp()
		calcVelocity(forward)
		face(velocity.x)
		calcAnimDuration()
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

func uppercut(var delta):
	if(!changeState(UPPERCUT)):
		calcDestination(distance, angle)
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

func punchFire():
	angle = clampAngle(angle, angle_clamp)
	angle_thrown = angle
	var projVelocity:Vector2 = Vector2(forward,0).rotated(deg2rad(angle))
	var projectile = punchProj.instance()
	get_parent().add_child(projectile)
	projectile.setBounds(bounds_x,bounds_y)
	projectile.setCollider(stun,angle_thrown,thrown,thrown_multiplier,proj_damage)
	projectile.transform = _EMITTER.global_transform
	projectile.velocity = projVelocity.normalized() * proj_speed
	projectile.speed = proj_speed
	return true

func spawnWeapon():
	weapon = weaponProj.instance()
	get_parent().add_child(weapon)
	weapon.setBounds(bounds_x,bounds_y)
	weapon.transform = _EMITTER.global_transform
	weapon.velocity = Vector2(0,0)
	return true

func victory():
	_ANIMATION.play("victory")

func loss():
	_ANIMATION.play("thrown")
	
func throwWeapon():
	calcAngleToOpp()
	angle_thrown = angle
	weapon.setCollider(stun,angle_thrown,thrown,thrown_multiplier,proj_damage)
	weapon.velocity = Vector2(forward,0).rotated(deg2rad(angle)) * proj_speed
	weapon.speed = proj_speed
	weapon = null
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
	if(!area.is_in_group("Sanosuke") && area.is_in_group("Projectile")):
		if(interruptAct()):
			stun_opp = area.stun
			angle_thrown_opp = area.angle_thrown
			thrown_opp = area.thrown
			damage_opp = area.damage
			thrown_multiplier_opp = area.thrown_multiplier
			return
	if(!area.is_in_group("Sanosuke") && !area.is_in_group("Projectile")):
		area.area_con.push_back(_COLLIDER)

func _on_Area2D_area_exited(area):
	if(!area.is_in_group("Sanosuke")  && !area.is_in_group("Projectile")):
		area.area_con.erase(_COLLIDER)
		area.hit_areas.erase(_COLLIDER)

func _on_Area2D_hit(stun_opp_h, angle_thrown_opp_h, thrown_opp_h, thrown_multiplier_opp_h, damage_opp_h):
	if(interruptAct()):
		stun_opp = stun_opp_h
		angle_thrown_opp = angle_thrown_opp_h
		thrown_opp = thrown_opp_h
		damage_opp = damage_opp_h
		thrown_multiplier_opp = thrown_multiplier_opp_h
