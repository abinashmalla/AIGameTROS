tool
extends VisualScriptCustomNode

func _get_caption():
	return "Queue Empty?"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_type(idx):
	return TYPE_ARRAY

func _get_input_value_port_name(idx):
	return "Queue"

func _has_input_sequence_port():
	return true
	
func _get_output_sequence_port_count():
	return 2

func _get_output_sequence_port_text(idx):
	match idx:
		0:
			return "Queued"
		1:
			return "Empty"

func _step(inputs,outputs,start_mode,working_mem):
	if(inputs[0].empty()):
		return 1
	else:
		return 0
