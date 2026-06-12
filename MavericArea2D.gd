extends Area2D

export var hit_frame:bool = false
export var stun:float
export var angle_thrown:float
export var thrown:int

var area_con:Array = []
var hit_areas:Array = []

var hit:bool = false
var stun_opp:float
var angle_thrown_opp:float
var thrown_opp:float

signal hit(stun_opp,angle_thrown_opp,thrown_opp)

func _physics_process(delta):
	if(hit_frame):
		for area in area_con:
			if(!hit_areas.has(area)):
				area.hit = true
				area.stun_opp = stun
				area.angle_thrown_opp = angle_thrown
				area.thrown_opp = thrown
				hit_areas.push_back(area)
	else:
		hit_areas = []
	
	if(hit):
		hit = false
		emit_signal("hit", stun_opp,angle_thrown_opp,thrown_opp)
