tool
extends VisualScriptCustomNode

enum {GETUP,IDLE,JUMP,RECOVER,ROLL,RUN,SANOSUKEPOWA,SANOSUKEPUNCH,
SANOSUKEWEAPONTHROW,STUN,THROWN,UPPERCUT,WALK,NULL_S}

func _get_caption():
	return "Random State Select"

func _has_input_sequence_port():
	return true

func _get_output_value_port_count():
	return 1

func _get_output_value_port_name(idx):
	return "State"

func _get_output_value_port_type(idx):
	return TYPE_INT

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var roll = rng.randi_range(7,9)
	
	outputs[0] = roll
	return 0
