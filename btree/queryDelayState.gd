tool
extends VisualScriptCustomNode

func _get_caption():
	return "Delayed State?"

func _get_input_value_port_count():
	return 1

func _get_input_value_port_type(idx):
	return TYPE_OBJECT

func _get_input_value_port_name(idx):
	return "Self"

func _has_input_sequence_port():
	return true

func _get_output_value_port_count():
	return 1

func _get_output_value_port_type(idx):
	return TYPE_INT

func _get_output_value_port_name(idx):
	return "State"

func _get_output_sequence_port_count():
	return 2

func _get_output_sequence_port_text(idx):
	match idx:
		0:
			return "Yes"
		1:
			return "No"

func _step(inputs,outputs,start_mode,working_mem):
	var delay_state:int = inputs[0].delay_state
	
	if(delay_state != -1):
		outputs[0] = delay_state
		inputs[0].delay_state = -1
		return 0
	else:
		return 1
