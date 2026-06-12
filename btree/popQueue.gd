tool
extends VisualScriptCustomNode

func _get_caption():
	return "Pop Queue"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_type(idx):
	return TYPE_ARRAY

func _get_input_value_port_name(idx):
	return "Queue"

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
	if(inputs[0].empty()):
		outputs[0] = 0
	else:
		outputs[0] = inputs[0].pop_front()
	
	return 0
