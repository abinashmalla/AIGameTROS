tool
extends VisualScriptCustomNode

func _get_caption():
	return "Select Execute Queue"

func _get_input_value_port_count():
	return 2

func _get_input_value_port_type(idx):
	match idx:
		0:
			return TYPE_OBJECT
		1:
			return TYPE_BOOL

func _get_input_value_port_name(idx):
	match idx:
		0:
			return "Self"
		1:
			return "lockedQ"

func _get_output_value_port_count():
	return 1

func _get_output_value_port_name(idx):
	return "State"
	
func _get_output_value_port_type(idx):
	return TYPE_INT 

func _has_input_sequence_port():
	return true

func _get_output_sequence_port_count():
	return 1

func _step(inputs,outputs,start_mode,working_mem):
	var lockedQ:bool = inputs[1]
	if(lockedQ):
		outputs[0] = inputs[0].state_queue_locked.pop_front()
	else:
		outputs[0] = inputs[0].state_queue.pop_front()
	return 0
