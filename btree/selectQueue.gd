tool
extends VisualScriptCustomNode

func _get_caption():
	return "Select Queue"

func _get_input_value_port_count():
	return 3

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_INT
		1:
			return TYPE_BOOL
		2:
			return TYPE_OBJECT

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "push"
		1:
			return "lockedQ"
		2:
			return "Self"

func _get_output_value_port_count():
	return 2

func _get_output_value_port_name(idx):
	match idx:
		0:
			return "push"
		1:
			return "Queue"
	
func _get_output_value_port_type(idx):
	match idx:
		0:
			return	TYPE_INT 
		1: 
			return TYPE_ARRAY

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	if(inputs[1] == true):
		outputs[1] = inputs[2].state_queue_locked
	else:
		outputs[1] = inputs[2].state_queue
	outputs[0] = inputs[0]
	return 0
