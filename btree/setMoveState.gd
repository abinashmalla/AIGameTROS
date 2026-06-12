tool
extends VisualScriptCustomNode

enum {ATTACK,ESCAPE}

func _get_caption():
	return "Set Move State"

func _get_input_value_port_count():
	return 2

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_STRING

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Self"
		1:
			return "ATTACK/ESCAPE"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	var move_state:String = inputs[1]

	if(move_state=="ESCAPE"):
		inputs[0].move_state = ESCAPE
	else:
		inputs[0].move_state = ATTACK
		
	return 0
