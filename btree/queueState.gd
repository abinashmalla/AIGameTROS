tool
extends VisualScriptCustomNode

func _get_caption():
	return "Queue State"

func _get_input_value_port_count():
	return 2

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_INT
		1:
			return TYPE_ARRAY

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "State"
		1:
			return "Queue Array"

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
		inputs[1].push_back(inputs[0])
		
		return 0
