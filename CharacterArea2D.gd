extends Area2D

export var iframe:bool = false
export var hit_frame:bool = false
export var stun:float
export var angle_thrown:float
export var thrown:int
export var thrown_multiplier:float
export var damage:int

var area_con:Array = []
var hit_areas:Array = []

var hit:bool = false
var stun_opp:float
var angle_thrown_opp:float
var thrown_opp:int
var thrown_multiplier_opp:float
var damage_opp:int

signal hit(stun_opp_h,angle_thrown_opp_h,thrown_opp_h,thrown_multiplier_opp_h,damage_opp_h)

func _physics_process(delta):
	if(hit_frame):
		for area in area_con:
			if(!hit_areas.has(area)):
				if(area.iframe):
					continue
				area.hit = true
				area.stun_opp = stun
				area.angle_thrown_opp = angle_thrown
				area.thrown_opp = thrown
				area.thrown_multiplier_opp = thrown_multiplier
				area.damage_opp = damage
				hit_areas.push_back(area)
	else:
		hit_areas = []
	
	if(hit):
		hit = false
		emit_signal("hit", stun_opp,angle_thrown_opp,thrown_opp,thrown_multiplier_opp,damage_opp)
