tool
extends VisualScriptCustomNode

enum {ATTACK,ESCAPE}

func _get_caption():
	return "Update State Parameters"

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
	var position:Vector2 = inputs[0].get("position")
	var position_opp:Vector2 = inputs[0].get("position_opp")
	var angle:float = inputs[0].get("angle")
	var attack_range:int = inputs[0].get("attack_range")
	var move_state:int = inputs[0].get("move_state")
	var escape_distance:int = inputs[0].get("escape_distance")
	
	var destination:Vector2 = Vector2(0,0)
	
	var rng = RandomNumberGenerator.new()
	var roll:float = 0
	var upper_limit:float = deg2rad(70)
	var lower_limit:float = deg2rad(70)
	
	angle = deg2rad(angle)
	
	rng.randomize()
	roll = rng.randf_range(lower_limit, upper_limit)
	match move_state:
		ATTACK:
			destination = position_opp + Vector2(cos(angle), sin(angle)) * attack_range
		ESCAPE:
			angle = roll + position.angle_to_point(position_opp)
			rng.randomize()
			escape_distance += rng.randi_range(0,170)
			destination = position + Vector2(cos(angle), sin(angle)) * escape_distance
	
	if(position.distance_to(destination) <= 10):
		destination = position
	
	angle = rad2deg(angle)

	inputs[0].set("angle", angle)
	inputs[0].set("destination", destination)
	return 0

