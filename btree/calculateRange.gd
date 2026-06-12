tool
extends VisualScriptCustomNode

func _get_caption():
	return "Calculate Range"

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
	var angle = position_opp.angle_to_point(position)
	angle = rad2deg(angle)	
	
	var angle_to_opp:float
	if(angle > 90):
		angle_to_opp = 180 - angle
	elif(angle < -90):
		angle_to_opp = -180 + abs(angle)
		
	var distance_to_opp:float = position.distance_to(position_opp)
	
	inputs[0].set("angle_to_opp", angle_to_opp)
	inputs[0].set("distance_to_opp", distance_to_opp)
	
	return 0
