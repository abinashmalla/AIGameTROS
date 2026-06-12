tool
extends VisualScriptCustomNode

enum {GETUP,IDLE,JUMP,RECOVER,ROLL,RUN,SANOSUKEPOWA,SANOSUKEPUNCH,
SANOSUKEWEAPONTHROW,STUN,THROWN,UPPERCUT,WALK,NULL_S}

func _get_caption():
	return "Probability Select"

func _has_input_sequence_port():
	return true

func _get_input_value_port_count():
	return 2

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "A(%)"
		1:
			return "B(%)"

func _get_input_value_port_type(idx):
	return TYPE_INT

func _get_output_sequence_port_count():
	return 2

func _get_output_sequence_port_text(idx):
	match idx:
		0:
			return "A"
		1:
			return "B"

func _step(inputs,outputs,start_mode,working_mem):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var roll = rng.randi_range(1,100)
	
	if roll > inputs[0]:
		return 1
	return 0
