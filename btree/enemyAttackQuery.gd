tool
extends VisualScriptCustomNode

func _get_caption():
	return "About to be Hit?"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_type(idx):
		return TYPE_OBJECT

func _get_input_value_port_name(idx):
		return "Self"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 2

func _get_output_sequence_port_text(idx):
	match idx:
		0:
			return "No"
		1:
			return "Yes"

func _step(inputs,outputs,start_mode,working_mem):
	var position:Vector2 = inputs[0].position
	var position_opp:Vector2 = inputs[0].position_opp
	var State_opp:int = inputs[0].State_opp
	var STATE_INFO_opp:Dictionary = inputs[0].STATE_INFO_opp
	var State:int = inputs[0].State
	var STATE_INFO:Dictionary = inputs[0].STATE_INFO
	var group_name:String = inputs[0].name
	var projectiles_all:Array = inputs[0].projectiles_all

	var distance_to_opp:float
	var enemy_attack_distance:float
	var proj_position:Vector2
	var proj_distance:float
	var proj_velocity:float
	var proj_hit_time:float
	
	#if in iframe or locked in follow
	if(STATE_INFO.get(State).has("iframe") || STATE_INFO.get(State).has("followed")):
		return 0
	
	for projectile in projectiles_all:
		if(!projectile.is_in_group(group_name)):
			proj_velocity = abs(projectile.velocity.length())
			if(proj_velocity == 0):
				continue
			proj_position = projectile.position
			var proj_angle = rad2deg(position.angle_to(proj_position))
			var angle_to_proj = rad2deg(proj_position.angle_to(position))
			if(abs(proj_angle-angle_to_proj) >= 30):
				continue
			var proj_direction:Vector2 = proj_position.direction_to(position)
			if((projectile.velocity.x * proj_direction.x) < 0):
				continue
			proj_distance = position.distance_to(proj_position)
			proj_hit_time = proj_distance/proj_velocity
			if(proj_hit_time <= 1 && proj_hit_time>0):
				return 1
	
	if(STATE_INFO_opp.get(State_opp).has("attack") && !STATE_INFO_opp.get(State_opp).has("projectile")):
		distance_to_opp = position.distance_to(position_opp)
		enemy_attack_distance = STATE_INFO_opp.get(State_opp).get("distance")
		if(distance_to_opp <= enemy_attack_distance):
#			print("defend")
			return 1
	
	return 0
