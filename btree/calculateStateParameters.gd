tool
extends VisualScriptCustomNode

enum {ATTACK,ESCAPE}

func _get_caption():
	return "Calculate State Parameters"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_type(idx):
		return TYPE_OBJECT

func _get_input_value_port_name(idx):
		return "Self"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	var State:int = inputs[0].get("new_state")
	var STATE_INFO:Dictionary = inputs[0].get("STATE_INFO")
	var position:Vector2 = inputs[0].get("position")
	var position_opp:Vector2 = inputs[0].get("position_opp")
	var attack_range:int = inputs[0].get("attack_range")
	var move_state:int = inputs[0].get("move_state")
	
	var distance_to_opp:float = position.distance_to(position_opp)
	
	var angle:float = 0
	var destination:Vector2 = Vector2(0,0)
	var duration:float = 0
	var escape_distance:int = 0
	
	var rng = RandomNumberGenerator.new()
	var roll:float = 0
	var upper_limit:float = deg2rad(70)
	var lower_limit:float = deg2rad(-70)
	
	rng.randomize()
	roll = rng.randf_range(lower_limit, upper_limit)
	match move_state:
		ATTACK:
			angle = position_opp.angle_to_point(position)
			destination = position_opp
			if(!STATE_INFO.get(State).has("skip")):
				continue
			angle += roll
			destination = position_opp + Vector2(cos(angle), sin(angle)) * attack_range
		ESCAPE:
			angle = roll + position.angle_to_point(position_opp)
			rng.randomize()
			escape_distance = rng.randi_range(340,710)
			destination = position + Vector2(cos(angle), sin(angle)) * escape_distance
	
	angle = rad2deg(angle)
	
	rng.randomize()
	roll = rng.randf_range(1,3)
	duration = roll

	inputs[0].set("angle", angle)
	inputs[0].set("destination", destination)
	inputs[0].set("duration", duration)
	inputs[0].set("escape_distance", escape_distance)
	return 0
